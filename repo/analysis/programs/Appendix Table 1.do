**********************************************************
*name: Appendix Table 1.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Descriptive statistics
**********************************************************
clear all 

use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta" 

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

foreach i in cannabis heroin_coke synth_narc other_drug {
	label var rate_sale_`i'_1899 "`i' Sales Arrest Rate"
	label var rate_poss_`i'_1899 "`i' Possession Arrest Rate"
}

label var rate_property_1899 "Property Arrest Rate"
label var rate_theft_1899 "Larceny Arrest Rate"
label var rate_mtr_veh_theft_1899 "MVT Arrest Rate"
label var rate_arson_1899 "Arson Arrest Rate"
label var rate_burglary_1899 "Burglary Arrest Rate"

label var rate_violent_1899 "Violent Arrest Rate"
label var rate_murder_1899 "Murder Arrest Rate"
label var rate_rape_1899 "Rape Arrest Rate"
label var rate_robbery_1899 "Robbery Arrest Rate"
label var rate_agg_assault_1899 "Assault Arrest Rate"

label var rate_vandalism_1899 "Vandalism Arrest Rate"
label var rate_liquor_1899 "Liquor Law Arrest Rate"
label var rate_drunkenness_1899 "Drunkenness Arrest Rate"
label var rate_disorder_cond_1899 "Disorderly Conduct Arrest Rate"


gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

label var num_agencies_report "Number of Agencies Reporting Arrests"
label var mml "Medical Marijuana Law"
label var decrim "Marijuana Decriminalization Law"
label var lnpolice_percapita "Ln(Police per Capita)"
label var unemployment "State Unemployment Rate"
label var pc_income "Personal Income per Capita"
label var prop_black "Share Non-Hispanic Black"
label var prop_hisp "Share Hispanic"
label var samaritan_alc "Good Samaritan Law - Alcohol"
label var samaritan_drug "Good Samaritan Law - Drug"
label var naloxone "Naloxone Access Law"
label var pdmp "Must-Access Prescription Drug Monotoring Program"
label var beer_tax "Beer Tax per Gallon"
label var minimum_wage "Minimum Wage"
label var acaexp "ACA Medicaid Expansion"
label var democrat "Democrat Governor"
label var eitc "EITC Refundable Rate"


****************
**# Descriptives 
****************
cd "$path\analysis\tables"

*Total Marijuana Arrests
estpost tabstat rate_total_cannabis_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1

esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page replace
    est clear 

*Sale
estpost tabstat rate_sale_cannabis_1899 rate_sale_heroin_coke_1899 rate_sale_synth_narc_1899 rate_sale_other_drug_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1

esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear  
	
*Possession	
estpost tabstat rate_poss_cannabis_1899 rate_poss_heroin_coke_1899 rate_poss_synth_narc_1899 rate_poss_other_drug_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear   
	
*Property
estpost tabstat rate_property_1899 rate_theft_1899 rate_burglary_1899 rate_mtr_veh_theft_1899 rate_arson_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear 	

*Violent 
estpost tabstat rate_violent_1899 rate_agg_assault_1899 rate_robbery_1899 rate_murder_1899 rate_rape_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear 	

*Part II
estpost tabstat rate_vandalism_1899 rate_liquor_1899 rate_drunkenness_1899 rate_dui_1899 rate_disorder_cond_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear 
	
*Covariates 
keep if race==1

estpost sum num_agencies_report mml decrim lnpolice_percapita unemployment pc_income prop_black prop_hisp samaritan_alc samaritan_drug naloxone pdmp beer_tax minimum_wage acaexp democrat eitc [aw=pop_1899]
	est store c1

esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(3)) sd(fmt(3) par) count(fmt(0))") ///
    nostar nonote title("Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear 
