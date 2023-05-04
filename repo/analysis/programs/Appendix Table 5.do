**********************************************************
*name: Appendix Table 5.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Arrest ratio estimates
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

**globals 
global lea "num_agencies_report"
global mml_mdl "mml decrim"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global sw_pol "lnmw acaexp democrat eitc"

gen race2="all"
replace race2="black" if race==2 
replace race2="white" if race==3

drop if race==1


**arrest ratio 
gen total_cannabis_ratio=total_cannabis_1899/total_1899
gen total_heroin_coke_ratio=total_heroin_coke_1899/total_1899
gen total_synth_narc_ratio=total_synth_narc_1899/total_1899
gen total_other_drug_ratio=total_other_drug_1899/total_1899

  
****************
**# Appendix Table 5
****************
cd "$path\analysis\tables"

**White
*c1
reghdfe total_cannabis_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==3, a(fips year) vce(cl fips)
	sum total_cannabis_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm = r(mean)
	est store c1 
	
*c2
reghdfe total_heroin_coke_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==3, a(fips year) vce(cl fips)
	sum total_heroin_coke_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm = r(mean)
	est store c2	

*c3
reghdfe total_synth_narc_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==3, a(fips year) vce(cl fips)
	sum total_synth_narc_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm = r(mean)
	est store c3
	
*c4
reghdfe total_other_drug_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==3, a(fips year) vce(cl fips)
	sum total_other_drug_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm = r(mean)
	est store c4

esttab c1 c2 c3 c4 using "Appendix Table 5.csv", label ///
	title("Appendix Table 5 - arrest ratio - white")  ///
	keep(rml) ///
	noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(4) sefmt(4) sfmt(4 0) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles("Marijuana Arrests" "Cocaine-Heroin Arrests" "Addicting Synthetic Narcotics Arrests" "Dangerous Non-Narcotic Arrests") nogaps se nonotes ///
	page replace 
	est clear 	
	
**Black 
*c1
reghdfe total_cannabis_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==2, a(fips year) vce(cl fips)
	sum total_cannabis_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm = r(mean)
	est store c1 
	
*c2
reghdfe total_heroin_coke_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==2, a(fips year) vce(cl fips)
	sum total_heroin_coke_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm = r(mean)
	est store c2	

*c3
reghdfe total_synth_narc_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==2, a(fips year) vce(cl fips)
	sum total_synth_narc_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm = r(mean)
	est store c3
	
*c4
reghdfe total_other_drug_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race==2, a(fips year) vce(cl fips)
	sum total_other_drug_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm = r(mean)
	est store c4

esttab c1 c2 c3 c4 using "Appendix Table 5.csv", label ///
	title("Appendix Table 5 - arrest ratio - black")  ///
	keep(rml) ///
	noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(4) sefmt(4) sfmt(4 0) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles("Marijuana Arrests" "Cocaine-Heroin Arrests" "Addicting Synthetic Narcotics Arrests" "Dangerous Non-Narcotic Arrests") nogaps se nonotes ///
	page append 
	est clear 	



clear 


