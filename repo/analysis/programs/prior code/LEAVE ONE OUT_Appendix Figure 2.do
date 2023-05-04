**********************************************************
*name: Appendix Figure 2.do
*author: Zach Fone (U.S. Air Force Academy)
*description: "Leave one out" estimate
*created: february 24, 2023
*updated: NA
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

**RML early adopters 
gen temp=year if rml!=0 & rml!=.
egen rml_year=min(temp), by(fips) 
drop temp 
gen early_adopter=inrange(rml_year, 2012, 2015)
tab state_abb early_adopter if ever_rml==1

/*
           |     early_adopter
 state_abb |         0          1 |     Total
-----------+----------------------+----------
        AK |         0         60 |        60 
        CA |        60          0 |        60 
        CO |         0         60 |        60 
        DC |         0         57 |        57 
        MA |        60          0 |        60 
        ME |        60          0 |        60 
        MI |        60          0 |        60 
        NV |        60          0 |        60 
        OR |         0         60 |        60 
        VT |        60          0 |        60 
        WA |         0         60 |        60 
-----------+----------------------+----------
     Total |       360        297 |       657 

*/

****************
**# Figure
****************
cd "$path\analysis\figures"

est clear

**full sample 
*white 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
est store white_full
*black 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
est store black_full

**dropping states one by one 
foreach i in AK CA CO DC MA ME MI NV OR VT WA {
	
	*white 
	reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white" & state_abb!="`i'", a(fips year) vce(cl fips)
	est store white_no`i'
	*black 
	reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black" & state_abb!="`i'", a(fips year) vce(cl fips)
	est store black_no`i'
	
}

**No early adopters
*white 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white" & early_adopter!=1, a(fips year) vce(cl fips)
est store white_noEA
*black 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black" & early_adopter!=1, a(fips year) vce(cl fips)
est store black_noEA

**Only early_adopters
*white 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white" & (early_adopter==1 | ever_rml==0), a(fips year) vce(cl fips)
est store white_onlyEA
*black 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black" & (early_adopter==1 | ever_rml==0), a(fips year) vce(cl fips)
est store black_onlyEA


coefplot white_full white_noAK white_noCA white_noCO white_noDC white_noMA white_noME white_noMI white_noNV white_noOR white_noVT white_noWA white_noEA white_onlyEA, bylabel("White") keep(rml) xline(0) ///
	aseq swapnames legend(off) eqrename(white_full = "Full Sample" white_noAK = "No AK" white_noCA = "No CA" white_noCO = "No CO" white_noDC = "No DC" white_noMA = "No MA" white_noME = "No ME" white_noMI = "No MI" white_noNV = "No NV" white_noOR = "No OR" white_noVT = "No VT" white_noWA = "No WA" white_noEA = "No Early Adopters" white_onlyEA = "Only Early Adopters") /// 
	|| black_full black_noAK black_noCA black_noCO black_noDC black_noMA black_noME black_noMI black_noNV black_noOR black_noVT black_noWA black_noEA black_onlyEA, bylabel("Black") subtitle(, bcolor(gs14)) keep(rml) xlabel(-750(150)150) xline(0) byopts(legend(off) graphregion(color(white))) ///
	aseq swapnames ciopts(recast(rcap) lcolor(black) lwidth(thin)) msize(small) lcolor(gs1) color(gs1) lwidth(thin) ///
	eqrename(black_full = "Full Sample" black_noAK = "No AK" black_noCA = "No CA" black_noCO = "No CO" black_noDC = "No DC" black_noMA = "No MA" black_noME = "No ME" black_noMI = "No MI" black_noNV = "No NV" black_noOR = "No OR" black_noVT = "No VT" black_noWA = "No WA" black_noEA = "No Early Adopters" black_onlyEA = "Only Early Adopters")
graph export "$path\analysis\figures\Appendix Figure 2_mj_tot.png", replace

*coefplot white_full white_noAK white_noCA black_full black_noAK black_noCA, keep(rml) xlabel(-750(150)150) xline(0) graphregion(color(white)) aseq swapnames legend(off) eqrename(white_full = "White: Full Sample" white_noAK = "White: No AK" white_noCA = "White: No CA" black_full = "Black: Full Sample")

clear 


