**********************************************************
*name: Appendix Table 2.do
*author: Zach Fone (US Air Force Academy)
*description: RML policy dates
**********************************************************
clear

****************************
**# RML to RML Sales
****************************
/* Data documentation:

From Table 1 of:

"Public Health Effects of Marijuana Legalization" - Anderson and Rees

*/
clear
import excel using "$path\data\ucr\data\policy\rml_mml_sales.xlsx", firstrow

keep state_name rml_date rml_sales 
keep if rml_date!=.
keep if rml_date<=td(31dec2019)

**more recent dispensary legalization
*Maine RML-Sales, 10/9/2020: https://www.mpp.org/news/press/legal-marijuana-sales-in-maine-to-begin-on-friday/
replace rml_sales=td(09oct2020) if state_name=="Maine"

*Vermont RML-Sales, 10/1/2022: https://www.mpp.org/states/vermont/
replace rml_sales=td(01oct2022) if state_name=="Vermont"

*Arizona RML-Sales, 1/22/2021: https://en.wikipedia.org/wiki/Cannabis_in_Arizona#:~:text=State%2Dlicensed%20sales%20of%20recreational,was%20approved%20in%20U.S.%20history.
replace rml_sales=td(22jan2021) if state_name=="Arizona"

*Connecticut RML-Sales, 1/10/2023: https://portal.ct.gov/DCP/News-Releases-from-the-Department-of-Consumer-Protection/2022-News-Releases/Consumer-Protection-Announces-Adult-Use-Cannabis-Market-Opening-Date
replace rml_sales=td(10jan2023) if state_name=="Connecticut"

*Montana RML-Sales, 1/1/2022: https://mtrevenue.gov/cannabis/faqs/#:~:text=As%20of%20January%201%2C%202022,by%20individuals%2021%20and%20over.
replace rml_sales=td(01jan2022) if state_name=="Montana"

*New Jersey RML-Sales, 4/21/2022: https://www.mpp.org/states/new-jersey/?state=NJ
replace rml_sales=td(21apr2022) if state_name=="New Jersey"

*New Mexico RML-Sales, 4/1/2022: https://www.mpp.org/states/new-mexico/?state=NM
replace rml_sales=td(01apr2022) if state_name=="New Mexico"

*New York (expects to start sales before end of 2022; https://theticker.org/9507/business/ny-issues-first-round-of-retail-licenses-for-recreational-marijuana-sales/)

*Virginia (looks like 2024 or later; https://www.axios.com/local/richmond/2022/09/30/virginia-retail-marijuana-legalization-2024)

*DC is a bit weird (https://www.leafly.com/learn/legalization/washington-dc)

**restrict to pre-2020 RML adopters
keep if rml_date<=td(31dec2019)

format rml_date %tdnn/dd/YY
format rml_sales %tdnn/dd/YY

label var state_name "State"
label var rml_date "RML Enactment Date"
label var rml_sales "Dispensary Legalization Date"

**export to excel
export excel using "$path\analysis\ucr\tables\Appendix Table 2.xlsx", firstrow(varlabels) replace


