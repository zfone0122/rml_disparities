**********************************************************
*name: Appendix Figure 5.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Event Study Analysis of RML Adoption and Black Adult Arrests
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.

label var rml "RML"

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

**interactions with black 
gen black=race==2
foreach i in number_of_months_reported report_share_seer unemployment pc_income prop_black prop_hisp democrat mml decrim beer_tax samaritan_alc samaritan_drug naloxone pdmp cig_tax ecigtax lnpolice_percapita eitc snap4 minimum_wage acaexp shall_law stand_ground lnmw lnbeer lnpci rml {
	gen `i'_black=`i'*black 
}
label var rml_black "Diff. in Coeff. (Black-White)"

**globals 
global lea "number_of_months_reported report_share_seer"
global lea_interx "number_of_months_reported report_share_seer number_of_months_reported_black report_share_seer_black"
global mml_mdl "mml decrim"
global mml_mdl_interx "mml mml_black decrim decrim_black"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global police_econ_interx "lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global drug_pol_interx "samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnbeer lnbeer_black"
global sw_pol "lnmw acaexp democrat eitc"
global sw_pol_interx "lnmw lnmw_black acaexp acaexp_black democrat democrat_black eitc eitc_black"
global sat_interx "number_of_months_reported report_share_seer number_of_months_reported_black report_share_seer_black mml mml_black lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black democrat democrat_black decrim decrim_black samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnmw lnmw_black acaexp acaexp_black lnbeer lnbeer_black eitc eitc_black"

gen race2="all"
replace race2="black" if race==2 
replace race2="white" if race==3

drop if race==1

****************
**# Figures
****************
cd "$path\analysis\ucr\figures"

*total
reghdfe rate_total_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==2, a(fips year) vce(cl fips)

coefplot, vertical keep(F5_rml F4_rml F3_rml F2_rml F1_rml L0_rml L1_rml L2_rml L3_rml) ///
	omitted ciopts(recast(rcap) lwidth(thin) color(navy)) msize(small) lcolor(navy) mcolor(navy) ///
	graphregion(color(white)) ///
	xline(5.5, lcolor(gs8)) ///
	xtitle(Years Relative to RML Enactment, size(small)) ///
	ytitle(Coefficient Estimate, size(small)) ///
	yline(0, lcolor(gs8)) ylabel(-3000(1000)3000,labsize(small)) 
	graph export "Appendix Figure 5_total.png", replace     
	est clear 
	
*drug 
reghdfe rate_total_drug_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==2, a(fips year) vce(cl fips)

coefplot, vertical keep(F5_rml F4_rml F3_rml F2_rml F1_rml L0_rml L1_rml L2_rml L3_rml) ///
	omitted ciopts(recast(rcap) lwidth(thin) color(navy)) msize(small) lcolor(navy) mcolor(navy) ///
	graphregion(color(white)) ///
	xline(5.5, lcolor(gs8)) ///
	xtitle(Years Relative to RML Enactment, size(small)) ///
	ytitle(Coefficient Estimate, size(small)) ///
	yline(0, lcolor(gs8)) ylabel(-1000(250)1000,labsize(small)) 
	graph export "Appendix Figure 5_drug.png", replace     
	est clear 
	


*marijuana
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol F* L* [pw=pop_1899] if race==2, a(fips year) vce(cl fips)

coefplot, vertical keep(F5_rml F4_rml F3_rml F2_rml F1_rml L0_rml L1_rml L2_rml L3_rml) ///
	omitted ciopts(recast(rcap) lwidth(thin) color(navy)) msize(small) lcolor(navy) mcolor(navy) ///
	graphregion(color(white)) ///
	xline(5.5, lcolor(gs8)) ///
	xtitle(Years Relative to RML Enactment, size(small)) ///
	ytitle(Coefficient Estimate, size(small)) ///
	yline(0, lcolor(gs8)) ylabel(-600(150)600,labsize(small)) 
	graph export "Appendix Figure 5_mj.png", replace     
	est clear 



clear 


	