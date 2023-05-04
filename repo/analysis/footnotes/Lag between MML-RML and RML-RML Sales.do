**********************************************************
*name: Lag between MML-RML and RML-RML Sales.do
*author: Zach Fone (US Air Force Academy)
*description: Time between MML and RML adoption AND time 
*             between RML adoption to when recreational 
*             sales begin at dispensaries
**********************************************************
clear

****************************
**# MML to RML 
****************************
use "$path\source_data\data\policy\rml-mml_2000-2019.dta", clear

keep year state_fips state rml mml 

gen temp=year if rml>0 & rml!=. 
egen rml_year=min(temp), by(state_fips)
drop temp 
gen rml_year2=rml_year+(1-rml) if year==rml_year 
egen temp=min(rml_year2), by(state_fips)
replace rml_year2=temp if rml_year2==. 
drop temp 

gen temp=year if mml>0 & mml!=. 
egen mml_year=min(temp), by(state_fips)
drop temp 
gen mml_year2=mml_year+(1-mml) if year==mml_year 
egen temp=min(mml_year2), by(state_fips)
replace mml_year2=temp if mml_year2==. 
drop temp 

collapse rml mml, by(state_fips state rml_year* mml_year*)

keep if rml_year!=.
gen lag_year=rml_year2-mml_year2 


****************************
**# RML to RML Sales
****************************
/* Data documentation:

From Table 1 in:

"Public Health Effects of Marijuana Legalization" - Anderson and Rees (2023)

*/
clear
import excel using "$path\source_data\data\policy\rml_mml_sales.xlsx", firstrow

keep state_name rml_date rml_sales 
keep if rml_date!=.

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

gen lag_days=rml_sales-rml_date 
gen lag_months=lag_days/30
gen lag_years=lag_days/365

label var lag_days "Days between RML to RML-Sales"
label var lag_months "Months between RML to RML-Sales"
label var lag_years "Years between RML to RML-Sales"

