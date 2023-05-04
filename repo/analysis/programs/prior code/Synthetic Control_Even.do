**********************************************************
*name: Synthetic Control_Even.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Matching on even pre-treatment years
*created: december 10, 2022
*updated: NA
**********************************************************
clear 

cd "$path\analysis\figures\synth\even\"

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) gen_vars 
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
  rml_effect |         40   -135.2522           0  -135.2522  -135.2522
       p_val |         40    .2380952           0   .2380952   .2380952
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) gen_vars 
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
  rml_effect |         40   -313.3726           0  -313.3726  -313.3726
       p_val |         40    .4761905           0   .4761905   .4761905
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) gen_vars 
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
  rml_effect |         40   -149.4467           0  -149.4467  -149.4467
       p_val |         40    .3333333           0   .3333333   .3333333
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) gen_vars 
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
  rml_effect |         40   -344.6635           0  -344.6635  -344.6635
       p_val |         40    .1428571           0   .1428571   .1428571
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) gen_vars 
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
  rml_effect |         40     -95.284           0    -95.284    -95.284
       p_val |         40    .3809524           0   .3809524   .3809524
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) gen_vars 
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
  rml_effect |         40   -282.7538           0  -282.7538  -282.7538
       p_val |         40    .2857143           0   .2857143   .2857143
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_mj_white.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) gen_vars 
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
  rml_effect |         40   -143.3755           0  -143.3755  -143.3755
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_mj_black.gph", replace
mat donor = e(W_weights)[1..20,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..20,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) gen_vars 
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
  rml_effect |         40   -372.2858           0  -372.2858  -372.2858
       p_val |         40    .3809524           0   .3809524   .3809524
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_mj_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) gen_vars 
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
  rml_effect |         43   -65.76748           0  -65.76748  -65.76748
       p_val |         43    .5416667           0   .5416667   .5416667
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_mj_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) gen_vars 
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
  rml_effect |         43   -149.2421           0  -149.2421  -149.2421
       p_val |         43          .5           0         .5         .5
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_mj_white.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) gen_vars 
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
  rml_effect |         43   -38.25335           0  -38.25335  -38.25335
       p_val |         43    .5416667           0   .5416667   .5416667
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_mj_black.gph", replace
mat donor = e(W_weights)[1..23,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..23,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) gen_vars 
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
  rml_effect |         43   -94.33538           0  -94.33538  -94.33538
       p_val |         43    .7083333           0   .7083333   .7083333
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



clear 


