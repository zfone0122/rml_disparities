**********************************************************
*name: Appendix Figure 2.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Synthetic Control Estimates
**********************************************************
clear 

cd "$path\analysis\ucr\figures\Appendix Figure 2\"

*******************************************************************
**# Marijuana
*******************************************************************
******************************************
**# Colorado [ trperiod(2013) ]
******************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

drop if race==1

egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==8)

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55     -139.33           0    -139.33    -139.33
       p_val |         55    .5277778           0   .5277778   .5277778
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -623.0734           0  -623.0734  -623.0734
       p_val |         55    .6388889           0   .6388889   .6388889
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
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2012.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(pos(6) cols(2) label(1 "CO-White") label(2 "Synth CO-White") label(3 "CO-Black") label(4 "Synth CO-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "CO_mj.png", replace 


******************************************
**# Washington [ trperiod(2013) ]
******************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

drop if race==1

egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==53)

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -157.1443           0  -157.1443  -157.1443
       p_val |         55    .6111111           0   .6111111   .6111111
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -441.3683           0  -441.3683  -441.3683
       p_val |         55    .4444444           0   .4444444   .4444444
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
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2012.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(pos(6) cols(2) label(1 "WA-White") label(2 "Synth WA-White") label(3 "WA-Black") label(4 "Synth WA-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "WA_mj.png", replace 


******************************************
**# Alaska [ trperiod(2015) ]
******************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

drop if race==1

egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==2)

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         35   -115.6463           0  -115.6463  -115.6463
       p_val |         35    .4722222           0   .4722222   .4722222
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         35   -271.6673           0  -271.6673  -271.6673
       p_val |         35    .6388889           0   .6388889   .6388889
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
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2014.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(pos(6) cols(2) label(1 "AK-White") label(2 "Synth AK-White") label(3 "AK-Black") label(4 "Synth AK-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "AK_mj.png", replace 


******************************************
**# Oregon [ trperiod(2015) ]
******************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

drop if race==1

egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==41)

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -199.2621           0  -199.2621  -199.2621
       p_val |         55    .0555556           0   .0555556   .0555556
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -962.9261           0  -962.9261  -962.9261
       p_val |         55    .0555556           0   .0555556   .0555556
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
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2014.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(pos(6) cols(2) label(1 "OR-White") label(2 "Synth OR-White") label(3 "OR-Black") label(4 "Synth OR-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "OR_mj.png", replace 


******************************************
**# California [ trperiod(2017) ]
******************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

drop if race==1

egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==6)

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -34.87829           0  -34.87829  -34.87829
       p_val |         55         .75           0        .75        .75
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -175.7569           0  -175.7569  -175.7569
       p_val |         55         .75           0        .75        .75
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
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2016.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(pos(6) cols(2) label(1 "CA-White") label(2 "Synth CA-White") label(3 "CA-Black") label(4 "Synth CA-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "CA_mj.png", replace 


******************************************
**# Massachusetts [ trperiod(2017) ]
******************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

drop if race==1

egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==25)

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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -75.07664           0  -75.07664  -75.07664
       p_val |         55    .7777778           0   .7777778   .7777778
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

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest 
mat donor = e(W_weights)[1..35,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..35,2]
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
  rml_effect |         55   -196.5483           0  -196.5483  -196.5483
       p_val |         55         .75           0        .75        .75
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
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2016.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(pos(6) cols(2) label(1 "MA-White") label(2 "Synth MA-White") label(3 "MA-Black") label(4 "Synth MA-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "MA_mj.png", replace 




clear 


