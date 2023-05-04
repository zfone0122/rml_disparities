**********************************************************
*name: Synthetic Control.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Synthetic Control Estimates
*created: november 4, 2022
*updated: november 29, 2022
**********************************************************
clear 

cd "$path\analysis\figures\synth\"

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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==8)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=8 & inrange(mml_year, 2008, 2019)) //CO adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40   -124.7373           0  -124.7373  -124.7373
       p_val |         40    .2857143           0   .2857143   .2857143
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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40   -218.0886           0  -218.0886  -218.0886
       p_val |         40    .6666667           0   .6666667   .6666667
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==53)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=53 & inrange(mml_year, 2008, 2019)) //WA adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40    -137.227           0   -137.227   -137.227
       p_val |         40    .5238096           0   .5238096   .5238096
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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40   -326.1932           0  -326.1932  -326.1932
       p_val |         40    .2857143           0   .2857143   .2857143
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==2)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=2 & inrange(mml_year, 2010, 2019)) //AK adopted RML in 2015

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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40   -43.47592           0  -43.47592  -43.47592
       p_val |         40    .5238096           0   .5238096   .5238096
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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40   -174.0137           0  -174.0137  -174.0137
       p_val |         40    .5238096           0   .5238096   .5238096
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==41)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=41 & inrange(mml_year, 2010, 2019)) //OR adopted RML in 2015

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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40   -147.2303           0  -147.2303  -147.2303
       p_val |         40     .047619           0    .047619    .047619
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
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
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
  rml_effect |         40    -352.551           0   -352.551   -352.551
       p_val |         40    .4285714           0   .4285714   .4285714
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==6)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=6 & inrange(mml_year, 2012, 2019)) //CA adopted RML in 2016 (but treating as if 2017, since was Nov 2016 adoption)

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
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
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
  rml_effect |         43   -29.50974           0  -29.50974  -29.50974
       p_val |         43    .7083333           0   .7083333   .7083333
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
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
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
  rml_effect |         43   -136.4775           0  -136.4775  -136.4775
       p_val |         43    .5416667           0   .5416667   .5416667
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==25)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=25 & inrange(mml_year, 2012, 2019)) //MA adopted RML in 2016 (but treating as if 2017, since was Dec 2016 adoption)

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
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
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
  rml_effect |         43    -39.5483           0   -39.5483   -39.5483
       p_val |         43    .6666667           0   .6666667   .6666667
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
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
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
  rml_effect |         43   -91.74754           0  -91.74754  -91.74754
       p_val |         43    .7916667           0   .7916667   .7916667
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

/* DC
******************************************
**# DC [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==11)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=11 & inrange(mml_year, 2010, 2019)) //DC adopted RML in Feb 2015

**need balanced panel 
*drop 2000 (don't have 2000 data for DC)
drop if year==2000
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=19 //No one dropped
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(11) trperiod(2015) resultsperiod(2001(1)2019) nest fig 
graph save "DC_mj_white.gph", replace
mat donor = e(W_weights)[1..21,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..21,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(11) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==11 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=11
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=11
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         38    -72.1757           0   -72.1757   -72.1757
       p_val |         38    .8181818           0   .8181818   .8181818
*/
save "DC_mj_white.dta", replace 

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(11) trperiod(2015) resultsperiod(2001(1)2019) nest fig 
graph save "DC_mj_black.gph", replace
mat donor = e(W_weights)[1..21,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..21,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(11) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==11 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=11
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=11
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         38   -43.39142           0  -43.39142  -43.39142
       p_val |         38    .8636364           0   .8636364   .8636364
*/
save "DC_mj_black.dta", replace 

restore 

**********************
*Combine figures 
**********************
use "DC_mj_white.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="white"
tempfile white
save `white'
use "DC_mj_black.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="black"
append using `white'

twoway (line treat year if race=="white", lcolor(navy)) (line synth year if race=="white", lcolor(navy) lpattern(dash)) (line treat year if race=="black", lcolor(maroon)) ///
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2012.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(50)300) graphregion(color(white)) legend(label(1 "DC-White") label(2 "Synth DC-White") label(3 "DC-Black") label(4 "Synth DC-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "DC_mj.png", replace 
*/


*******************************************************************
**# Non-Marijuana
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==8)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=8 & inrange(mml_year, 2008, 2019)) //CO adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_non-mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -.2459008           0  -.2459008  -.2459008
       p_val |         40    .1904762           0   .1904762   .1904762
*/
save "CO_non-mj_white.dta", replace 

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_non-mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    102.3103           0   102.3103   102.3103
       p_val |         40    .7619048           0   .7619048   .7619048
*/
save "CO_non-mj_black.dta", replace 

restore 


******************************************
**# Washington [ trperiod(2013) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==53)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=53 & inrange(mml_year, 2008, 2019)) //WA adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_non-mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -66.27942           0  -66.27942  -66.27942
       p_val |         40    .9047619           0   .9047619   .9047619
*/
save "WA_non-mj_white.dta", replace 

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_non-mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -70.88681           0  -70.88681  -70.88681
       p_val |         40           1           0          1          1
*/
save "WA_non-mj_black.dta", replace 

restore 


******************************************
**# Alaska [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==2)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=2 & inrange(mml_year, 2010, 2019)) //AK adopted RML in 2015

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_non-mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -99.81715           0  -99.81715  -99.81715
       p_val |         40    .1428571           0   .1428571   .1428571
*/
save "AK_non-mj_white.dta", replace 

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_non-mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -158.1572           0  -158.1572  -158.1572
       p_val |         40    .5714286           0   .5714286   .5714286
*/
save "AK_non-mj_black.dta", replace 

restore 


******************************************
**# Oregon [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==41)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=41 & inrange(mml_year, 2010, 2019)) //OR adopted RML in 2015

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_non-mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -.0283805           0  -.0283805  -.0283805
       p_val |         40     .952381           0    .952381    .952381
*/
save "OR_non-mj_white.dta", replace 

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_non-mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40      79.908           0     79.908     79.908
       p_val |         40           1           0          1          1
*/
save "OR_non-mj_black.dta", replace 

restore 


******************************************
**# California [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==6)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=6 & inrange(mml_year, 2012, 2019)) //CA adopted RML in 2016 (but treating as if 2017, since was Nov 2016 adoption)

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_non-mj_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43    492.1394           0   492.1394   492.1394
       p_val |         43        .875           0       .875       .875
*/
save "CA_non-mj_white.dta", replace 

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_non-mj_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43    253.5436           0   253.5436   253.5436
       p_val |         43    .8333333           0   .8333333   .8333333
*/
save "CA_non-mj_black.dta", replace 

restore 


******************************************
**# Massachusetts [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==25)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=25 & inrange(mml_year, 2012, 2019)) //MA adopted RML in 2016 (but treating as if 2017, since was Dec 2016 adoption)

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_non-mj_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43   -60.08345           0  -60.08345  -60.08345
       p_val |         43    .3333333           0   .3333333   .3333333
*/
save "MA_non-mj_white.dta", replace 

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

synth rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_non-mj_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_nonmj_1899 rate_total_nonmj_1899(2000) rate_total_nonmj_1899(2001) rate_total_nonmj_1899(2002) rate_total_nonmj_1899(2003) rate_total_nonmj_1899(2004) rate_total_nonmj_1899(2005) rate_total_nonmj_1899(2006) rate_total_nonmj_1899(2007) rate_total_nonmj_1899(2008) rate_total_nonmj_1899(2009) rate_total_nonmj_1899(2010) rate_total_nonmj_1899(2011) rate_total_nonmj_1899(2012) rate_total_nonmj_1899(2013) rate_total_nonmj_1899(2014) rate_total_nonmj_1899(2015) rate_total_nonmj_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_nonmj_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_nonmj_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43   -96.02751           0  -96.02751  -96.02751
       p_val |         43         .75           0        .75        .75
*/
save "MA_non-mj_black.dta", replace 

restore 


*******************************************************************
**# Property
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==8)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=8 & inrange(mml_year, 2008, 2019)) //CO adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_property_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40     162.492           0    162.492    162.492
       p_val |         40    .5238096           0   .5238096   .5238096
*/
save "CO_property_white.dta", replace 

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_property_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    233.8558           0   233.8558   233.8558
       p_val |         40    .7619048           0   .7619048   .7619048
*/
save "CO_property_black.dta", replace 

restore 


******************************************
**# Washington [ trperiod(2013) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==53)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=53 & inrange(mml_year, 2008, 2019)) //WA adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_property_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    26.96842           0   26.96842   26.96842
       p_val |         40    .6190476           0   .6190476   .6190476
*/
save "WA_property_white.dta", replace 

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_property_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    91.87463           0   91.87463   91.87463
       p_val |         40           1           0          1          1
*/
save "WA_property_black.dta", replace 

restore 


******************************************
**# Alaska [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==2)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=2 & inrange(mml_year, 2010, 2019)) //AK adopted RML in 2015

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_property_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -20.52159           0  -20.52159  -20.52159
       p_val |         40    .4761905           0   .4761905   .4761905
*/
save "AK_property_white.dta", replace 

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_property_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -105.0657           0  -105.0657  -105.0657
       p_val |         40    .8095238           0   .8095238   .8095238
*/
save "AK_property_black.dta", replace 

restore 


******************************************
**# Oregon [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==41)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=41 & inrange(mml_year, 2010, 2019)) //OR adopted RML in 2015

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_property_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    63.45721           0   63.45721   63.45721
       p_val |         40    .8571429           0   .8571429   .8571429
*/
save "OR_property_white.dta", replace 

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_property_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    -307.468           0   -307.468   -307.468
       p_val |         40     .952381           0    .952381    .952381
*/
save "OR_property_black.dta", replace 

restore 


******************************************
**# California [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==6)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=6 & inrange(mml_year, 2012, 2019)) //CA adopted RML in 2016 (but treating as if 2017, since was Nov 2016 adoption)

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_property_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43    7.877713           0   7.877713   7.877713
       p_val |         43    .9166667           0   .9166667   .9166667
*/
save "CA_property_white.dta", replace 

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_property_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43   -2.628026           0  -2.628026  -2.628026
       p_val |         43    .5416667           0   .5416667   .5416667
*/
save "CA_property_black.dta", replace 

restore 


******************************************
**# Massachusetts [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==25)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=25 & inrange(mml_year, 2012, 2019)) //MA adopted RML in 2016 (but treating as if 2017, since was Dec 2016 adoption)

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_property_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43   -30.09297           0  -30.09297  -30.09297
       p_val |         43    .7083333           0   .7083333   .7083333
*/
save "MA_property_white.dta", replace 

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

synth rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_property_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_property_1899 rate_property_1899(2000) rate_property_1899(2001) rate_property_1899(2002) rate_property_1899(2003) rate_property_1899(2004) rate_property_1899(2005) rate_property_1899(2006) rate_property_1899(2007) rate_property_1899(2008) rate_property_1899(2009) rate_property_1899(2010) rate_property_1899(2011) rate_property_1899(2012) rate_property_1899(2013) rate_property_1899(2014) rate_property_1899(2015) rate_property_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_property_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_property_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43   -87.69912           0  -87.69912  -87.69912
       p_val |         43    .7916667           0   .7916667   .7916667
*/
save "MA_property_black.dta", replace 

restore 


*******************************************************************
**# Violent
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

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==8)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=8 & inrange(mml_year, 2008, 2019)) //CO adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_violent_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    2.352478           0   2.352478   2.352478
       p_val |         40    .5714286           0   .5714286   .5714286
*/
save "CO_violent_white.dta", replace 

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_violent_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    143.3623           0   143.3623   143.3623
       p_val |         40    .1428571           0   .1428571   .1428571
*/
save "CO_violent_black.dta", replace 

restore 


******************************************
**# Washington [ trperiod(2013) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==53)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=53 & inrange(mml_year, 2008, 2019)) //WA adopted RML in 2012 (but treating as if 2013, since was Dec 2012 adoption)

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_violent_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    -3.55369           0   -3.55369   -3.55369
       p_val |         40    .1428571           0   .1428571   .1428571
*/
save "WA_violent_white.dta", replace 

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_violent_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    58.02202           0   58.02202   58.02202
       p_val |         40    .2857143           0   .2857143   .2857143
*/
save "WA_violent_black.dta", replace 

restore 


******************************************
**# Alaska [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==2)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=2 & inrange(mml_year, 2010, 2019)) //AK adopted RML in 2015

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_violent_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    -34.5432           0   -34.5432   -34.5432
       p_val |         40    .8571429           0   .8571429   .8571429
*/
save "AK_violent_white.dta", replace 

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_violent_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40    200.3668           0   200.3668   200.3668
       p_val |         40    .3809524           0   .3809524   .3809524
*/
save "AK_violent_black.dta", replace 

restore 


******************************************
**# Oregon [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==41)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=41 & inrange(mml_year, 2010, 2019)) //OR adopted RML in 2015

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_violent_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -.8107275           0  -.8107275  -.8107275
       p_val |         40    .4285714           0   .4285714   .4285714
*/
save "OR_violent_white.dta", replace 

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_violent_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         40   -153.1066           0  -153.1066  -153.1066
       p_val |         40    .5714286           0   .5714286   .5714286
*/
save "OR_violent_black.dta", replace 

restore 


******************************************
**# California [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==6)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=6 & inrange(mml_year, 2012, 2019)) //CA adopted RML in 2016 (but treating as if 2017, since was Nov 2016 adoption)

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_violent_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43    90.05334           0   90.05334   90.05334
       p_val |         43           1           0          1          1
*/
save "CA_violent_white.dta", replace 

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_violent_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43    155.3887           0   155.3887   155.3887
       p_val |         43    .1666667           0   .1666667   .1666667
*/
save "CA_violent_black.dta", replace 

restore 


******************************************
**# Massachusetts [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

non-RML adopting states that either never did an MML or enacted an MML at least like 6 years prior to the date of RML enactment

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==25)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=25 & inrange(mml_year, 2012, 2019)) //MA adopted RML in 2016 (but treating as if 2017, since was Dec 2016 adoption)

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_violent_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43   -18.33657           0  -18.33657  -18.33657
       p_val |         43        .875           0       .875       .875
*/
save "MA_violent_white.dta", replace 

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

synth rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_violent_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_violent_1899 rate_violent_1899(2000) rate_violent_1899(2001) rate_violent_1899(2002) rate_violent_1899(2003) rate_violent_1899(2004) rate_violent_1899(2005) rate_violent_1899(2006) rate_violent_1899(2007) rate_violent_1899(2008) rate_violent_1899(2009) rate_violent_1899(2010) rate_violent_1899(2011) rate_violent_1899(2012) rate_violent_1899(2013) rate_violent_1899(2014) rate_violent_1899(2015) rate_violent_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_violent_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_violent_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         43   -106.8725           0  -106.8725  -106.8725
       p_val |         43           1           0          1          1
*/
save "MA_violent_black.dta", replace 

restore 



clear 


