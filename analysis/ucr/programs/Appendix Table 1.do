**********************************************************
*name: Appendix Table 1.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Descriptive statistics
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

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


****************
**# Descriptives 
****************
cd "$path\analysis\ucr\tables"

*Total Marijuana Arrests
estpost tabstat rate_total_cannabis_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1

esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Appendix Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page replace
    est clear 

*Sale
estpost tabstat rate_sale_cannabis_1899 rate_sale_heroin_coke_1899 rate_sale_synth_narc_1899 rate_sale_other_drug_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1

esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Appendix Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear  
	
*Possession	
estpost tabstat rate_poss_cannabis_1899 rate_poss_heroin_coke_1899 rate_poss_synth_narc_1899 rate_poss_other_drug_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Appendix Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear   
	
*Property
estpost tabstat rate_property_1899 rate_theft_1899 rate_burglary_1899 rate_mtr_veh_theft_1899 rate_arson_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Appendix Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear 	

*Violent 
estpost tabstat rate_violent_1899 rate_agg_assault_1899 rate_robbery_1899 rate_murder_1899 rate_rape_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Appendix Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear 	

*Part II
estpost tabstat rate_vandalism_1899 rate_liquor_1899 rate_drunkenness_1899 rate_dui_1899 rate_disorder_cond_1899 [aw=pop_1899], by(race) stats(mean sd n) columns(statistics) nototal
	est store c1
	
esttab c1 using "Appendix Table 1.csv", label ///
    main(mean) aux(sd count) cell("mean(fmt(1)) sd(fmt(1) par) count(fmt(0))") ///
    nostar nonote title("Appendix Table 1") ///
    mtitles("Mean" "(SD)" "N") ///
    addnote("Notes: ") ///
    nogaps noobs page append
    est clear 
	


clear


