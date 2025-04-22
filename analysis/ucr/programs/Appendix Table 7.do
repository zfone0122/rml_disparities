**********************************************************
*name: Appendix Table 7.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Sensitivity of Estimated Arrest Effects to UCR 
*             Data Quality Checks and Using Unweighted Estimates
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_agency-year-race_2000-2019_analysis data.dta", clear

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.
label var rml "RML"

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

**interactions with black 
gen black=race==2
foreach i in unemployment pc_income prop_black prop_hisp democrat mml decrim beer_tax samaritan_alc samaritan_drug naloxone pdmp cig_tax ecigtax lnpolice_percapita eitc snap4 minimum_wage acaexp shall_law stand_ground lnmw lnbeer lnpci rml {
	gen `i'_black=`i'*black 
}
label var rml_black "Diff. in Coeff. (Black-White)"

**globals 
global sat_interx_agency "mml mml_black lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black democrat democrat_black decrim decrim_black samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnmw lnmw_black acaexp acaexp_black lnbeer lnbeer_black eitc eitc_black"
global mml_mdl "mml decrim"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global sw_pol "lnmw acaexp democrat eitc"

gen race2="all"
replace race2="black" if race==2 
replace race2="white" if race==3

drop if race==1

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000


****************
**# Appendix Table 7 
****************
cd "$path\analysis\ucr\tables"

***Panel I: OLS
foreach i in black white {
	
	*c1
	reghdfe rate_total_cannabis_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(ori_num year) vce(cl fips)
		sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c1 
		
	*c2
	reghdfe rate_total_nonmj_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(ori_num year) vce(cl fips)
		sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c2	
		
	*c3
	reghdfe rate_property_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(ori_num year) vce(cl fips)
		sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c3		

	*c4
	reghdfe rate_violent_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="`i'", a(ori_num year) vce(cl fips)
		sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c4
		
	esttab c1 c2 c3 c4 using "Appendix Table 7.csv", label ///
		title("OLS - agency level estimates - `i' ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(2) sefmt(2) sfmt(2 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") ///
		nogaps se nonotes ///
		page append 
		est clear 	

}

**difference in coefficients
	*c1
	reghdfe rate_total_cannabis_1899 $sat_interx_agency rml rml_black [pw=pop_1899] if race!=1, a(i.ori_num#i.black i.year#i.black) vce(cl fips)
		est store c1 
		
	*c2
	reghdfe rate_total_nonmj_1899 $sat_interx_agency rml rml_black [pw=pop_1899] if race!=1, a(i.ori_num#i.black i.year#i.black) vce(cl fips)
		est store c2	
		
	*c3
	reghdfe rate_property_1899 $sat_interx_agency rml rml_black [pw=pop_1899] if race!=1, a(i.ori_num#i.black i.year#i.black) vce(cl fips)
		est store c3		

	*c4
	reghdfe rate_violent_1899 $sat_interx_agency rml rml_black [pw=pop_1899] if race!=1, a(i.ori_num#i.black i.year#i.black) vce(cl fips)
		est store c4
		
	esttab c1 c2 c3 c4 using "Appendix Table 7.csv", label ///
		title("OLS - agency level estimates - diff in RML coeff. ")  ///
		keep(rml_black) ///
		noobs bfmt(2) sefmt(2) scalars("N N") sfmt(0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") ///
		nogaps se nonotes ///
		page append 
		est clear 	
		

***Panel II: Poisson
foreach i in black white {
	
	*c1
	ppmlhdfe total_cannabis_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml if race2=="`i'" & pop_1899>0 & pop_1899!=., a(ori_num year) exposure(pop_1899) vce(cl fips)
		sum total_cannabis_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c1 
		
	*c2
	ppmlhdfe total_nonmj_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml if race2=="`i'" & pop_1899>0 & pop_1899!=., a(ori_num year) exposure(pop_1899) vce(cl fips)
		sum total_nonmj_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c2	
		
	*c3
	ppmlhdfe property_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml if race2=="`i'" & pop_1899>0 & pop_1899!=., a(ori_num year) exposure(pop_1899) vce(cl fips)
		sum property_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c3		

	*c4
	ppmlhdfe violent_1899 $mml_mdl $police_econ $drug_pol $sw_pol rml if race2=="`i'" & pop_1899>0 & pop_1899!=., a(ori_num year) exposure(pop_1899) vce(cl fips)
		sum violent_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c4
		
	esttab c1 c2 c3 c4 using "Appendix Table 7.csv", label ///
		title("Poisson - agency level estimates - `i' ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(3) sefmt(3) sfmt(2 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") ///
		nogaps se nonotes ///
		page append 
		est clear 	

}

**difference in coefficients
	*c1
	ppmlhdfe total_cannabis_1899 $sat_interx_agency rml rml_black if race!=1 & pop_1899>0 & pop_1899!=., a(i.ori_num#i.black i.year#i.black) exposure(pop_1899) vce(cl fips)
		est store c1 
		
	*c2
	ppmlhdfe total_nonmj_1899 $sat_interx_agency rml rml_black if race!=1 & pop_1899>0 & pop_1899!=., a(i.ori_num#i.black i.year#i.black) exposure(pop_1899) vce(cl fips)
		est store c2	
		
	*c3
	ppmlhdfe property_1899 $sat_interx_agency rml rml_black if race!=1 & pop_1899>0 & pop_1899!=., a(i.ori_num#i.black i.year#i.black) exposure(pop_1899) vce(cl fips)
		est store c3		

	*c4
	ppmlhdfe violent_1899 $sat_interx_agency rml rml_black if race!=1 & pop_1899>0 & pop_1899!=., a(i.ori_num#i.black i.year#i.black) exposure(pop_1899) vce(cl fips)
		est store c4
		
	esttab c1 c2 c3 c4 using "Appendix Table 7.csv", label ///
		title("Poisson - agency level estimates - diff in RML coeff. ")  ///
		keep(rml_black) ///
		noobs bfmt(3) sefmt(3) scalars("N N") sfmt(0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") ///
		nogaps se nonotes ///
		page append 
		est clear 	

		
***Panel III: OLS - state-year unweighted
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

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

**estimates 
foreach i in black white {
	
	*c1
	reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml  if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_total_cannabis_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c1
		
	*c2
	reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml  if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_total_nonmj_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c2	
		
	*c3
	reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml  if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_property_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c3	
		
	*c4
	reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml  if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_violent_1899 if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c4

esttab c1 c2 c3 c4 using "Appendix Table 7.csv", label ///
		title("OLS-unweighted - state-year - `i' ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(2) sefmt(2) sfmt(2 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") nogaps se nonotes ///
		page append 
		est clear 	

}

**difference in coefficients
	*c1
	reghdfe rate_total_cannabis_1899 $sat_interx rml rml_black if race!=1 , a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c1 
			
	*c2
	reghdfe rate_total_nonmj_1899 $sat_interx rml rml_black if race!=1 , a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c2	
			
	*c3
	reghdfe rate_property_1899 $sat_interx rml rml_black if race!=1 , a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c3
		
	*c4
	reghdfe rate_violent_1899 $sat_interx rml rml_black if race!=1 , a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c4
		
	esttab c1 c2 c3 c4 using "Appendix Table 7.csv", label ///
		title("OLS-unweighted - state-year - diff in RML coeff. ")  ///
		keep(rml_black) ///
		noobs bfmt(2) sefmt(2) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") nogaps se nonotes ///
		page append 
		est clear 

	

clear


