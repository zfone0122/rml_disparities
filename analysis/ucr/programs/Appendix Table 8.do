**********************************************************
*name: Appendix Table 8.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Sensitivity of Estimated Drug Arrest Effects 
*             to Use of the Drug Arrest Ratio as the Dependent Variable
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

**arrest ratio 
gen total_cannabis_ratio=total_cannabis_1899/total_1899
gen total_heroin_coke_ratio=total_heroin_coke_1899/total_1899
gen total_synth_narc_ratio=total_synth_narc_1899/total_1899
gen total_other_drug_ratio=total_other_drug_1899/total_1899

****************
**# Appendix Table 8 
****************
cd "$path\analysis\ucr\tables"
cap erase "Appendix Table 8.csv"

foreach i in black white {
	
	*c1
	reghdfe total_cannabis_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(fips year) vce(cl fips)
		sum total_cannabis_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c1
		
	*c2
	reghdfe total_heroin_coke_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(fips year) vce(cl fips)
		sum total_heroin_coke_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c2	
		
	*c3
	reghdfe total_synth_narc_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(fips year) vce(cl fips)
		sum total_synth_narc_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c3	
		
	*c4
	reghdfe total_other_drug_ratio $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(fips year fips year) vce(cl fips)
		sum total_other_drug_ratio [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c4

esttab c1 c2 c3 c4 using "Appendix Table 8.csv", label ///
		title("Appendix Table 8 - `i' ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(4) sefmt(4) sfmt(4 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Cocaine-Heroin" "Addicting Synthetic Narcotics" "Dangerous Non-Narcotic") nogaps se nonotes ///
		page append 
		est clear 	

}

		

clear 



