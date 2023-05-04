**********************************************************
*name: Figure 2.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Event-Study Analyses of RMLs and Race-Specific Non-Marijuana Drug Arrests, 
*             TWFE Estimates
*created: october 25, 2022
*updated: november 18, 2022
**********************************************************
clear all 

use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta" 

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

gen t1=year-1999

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.

label var rml "RML"

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

**interactions with black 
gen black=race==2
foreach i in num_agencies_report unemployment pc_income prop_black prop_hisp democrat mml decrim beer_tax samaritan_alc samaritan_drug naloxone pdmp cig_tax ecigtax lnpolice_percapita eitc snap4 minimum_wage acaexp shall_law stand_ground lnmw lnbeer lnpci rml {
	gen `i'_black=`i'*black 
}
label var rml_black "RML*Black"

**globals 
global lea "num_agencies_report"
global mml_mdl "mml decrim"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global sw_pol "lnmw acaexp democrat eitc"
global sat_interx "num_agencies_report num_agencies_report_black mml mml_black lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black democrat democrat_black decrim decrim_black samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnmw lnmw_black acaexp acaexp_black lnbeer lnbeer_black eitc eitc_black"

gen race2="all"
replace race2="black" if race==2 
replace race2="white" if race==3

drop if race==1

****************
**# Figures
****************
cd "$path\analysis\figures"

**Panel A: Cocaine-Heroin Arrests 
	*c1 - white 
	reghdfe rate_total_heroin_coke_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==3, a(fips year) vce(cl fips)
		est store c1w
		
	*c1 - black 
	reghdfe rate_total_heroin_coke_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==2, a(fips year) vce(cl fips)
		est store c1b
		
	coefplot (c1w, offset(-0.15)) (c1b, offset(0.15)),  ///
	vertical keep(F* L*) plotlabels("White" "Black") ///
	omitted ciopts(recast(rcap) lwidth(thin)) msize(small) ///
	graphregion(color(white)) recast(connected) ///
	xline(5.5, lcolor(gs8)) ///
	xtitle(Years Relative to RML Enactment, size(small)) ///
	ytitle(Coefficient Estimate, size(small)) ///
	yline(0, lcolor(gs8)) ylabel(-450(150)450,labsize(small))
	graph save "Figure 2_coke_tot.gph", replace     
	graph export "Figure 2_coke_tot.png", replace     
	est clear 
	
**Panel B: Synthetic Narcotic Arrests 
	*c1 - white 
	reghdfe rate_total_synth_narc_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==3, a(fips year) vce(cl fips)
		est store c1w
		
	*c1 - black 
	reghdfe rate_total_synth_narc_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==2, a(fips year) vce(cl fips)
		est store c1b
		
	coefplot (c1w, offset(-0.15)) (c1b, offset(0.15)),  ///
	vertical keep(F* L*) plotlabels("White" "Black") ///
	omitted ciopts(recast(rcap) lwidth(thin)) msize(small) ///
	graphregion(color(white)) recast(connected) ///
	xline(5.5, lcolor(gs8)) ///
	xtitle(Years Relative to RML Enactment, size(small)) ///
	ytitle(Coefficient Estimate, size(small)) ///
	yline(0, lcolor(gs8)) ylabel(-60(20)60,labsize(small))
	graph save "Figure 2_snarc_tot.gph", replace     
	graph export "Figure 2_snarc_tot.png", replace     
	est clear 	
	
**Panel C: Other Drug Arrests 
	*c1 - white 
	reghdfe rate_total_other_drug_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==3, a(fips year) vce(cl fips)
		est store c1w
		
	*c1 - black 
	reghdfe rate_total_other_drug_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==2, a(fips year) vce(cl fips)
		est store c1b
		
	coefplot (c1w, offset(-0.15)) (c1b, offset(0.15)),  ///
	vertical keep(F* L*) plotlabels("White" "Black") ///
	omitted ciopts(recast(rcap) lwidth(thin)) msize(small) ///
	graphregion(color(white)) recast(connected) ///
	xline(5.5, lcolor(gs8)) ///
	xtitle(Years Relative to RML Enactment, size(small)) ///
	ytitle(Coefficient Estimate, size(small)) ///
	yline(0, lcolor(gs8)) ylabel(-225(75)225,labsize(small))
	graph save "Figure 2_odrug_tot.gph", replace     
	graph export "Figure 2_odrug_tot.png", replace     
	est clear 		



clear 


	