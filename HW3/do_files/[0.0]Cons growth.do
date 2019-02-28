//Development HW3
/**
Created by: Alba Miñano Mañero
Date: February 2019
Purpose: HW3 COmpute aggregate consumption growth 
*/


clear all
set type double
set more off
	

	global mpath "/Users/albaminano/Dropbox/Development/HW3"
	global path "$mpath"
	gl temp "$path/temp"
	gl data "$path/data"
	gl do "$path/do_files"
	gl output "$path/output"

 
 use "$data/dataUGA.dta", clear
 
/*********************
QUESTION 1
*******************/

drop if ctotal==0 | ctotal==.
drop if inctotal==0 |inctotal==.
generate log_c=log(ctotal)
generate log_income = log(inctotal)
gen rural = 1-urban

replace year = 2009 if wave =="2009-2010"
replace year = 2010 if wave == "2010-2011"

xtset hh year

 // Drop observations that appear only one year 
 drop if counthh <= 2
 


// Obtain average consumption
by region year urban, sort: egen cons_agg = sum(ctotal)
gen logConsAgg = log(cons_agg)
sort region urban year

collapse (mean) logConsAgg, by(region urban year)

sort region urban year

by region urban: gen growth_agg = (logConsAgg - logConsAgg[_n-1])

save "$temp/growthCons.dta", replace

/*Rural*/
 use "$data/dataUGA.dta", clear

keep if urban == 0
drop if ctotal==0 | ctotal==.
drop if inctotal==0 |inctotal==.
generate log_c=log(ctotal)
generate log_income = log(inctotal)
gen rural = 1-urban

replace year = 2009 if wave =="2009-2010"
replace year = 2010 if wave == "2010-2011"

xtset hh year

 // Drop observations that appear only one year 
 drop if counthh <= 2
 


// Obtain average consumption
by region year, sort: egen cons_agg = sum(ctotal)
gen logConsAgg = log(cons_agg)
sort region urban year

collapse (mean) logConsAgg, by(region urban year)

sort region  year

by region: gen growth_agg = (logConsAgg - logConsAgg[_n-1])

save "$temp/growthConsrural.dta", replace

/*Urban*/

 use "$data/dataUGA.dta", clear

keep if urban == 1
drop if ctotal==0 | ctotal==.
drop if inctotal==0 |inctotal==.
generate log_c=log(ctotal)
generate log_income = log(inctotal)
gen rural = 1-urban

replace year = 2009 if wave =="2009-2010"
replace year = 2010 if wave == "2010-2011"

xtset hh year

 // Drop observations that appear only one year 
 drop if counthh <= 2
 


// Obtain average consumption
by region year, sort: egen cons_agg = sum(ctotal)
gen logConsAgg = log(cons_agg)
sort region urban year

collapse (mean) logConsAgg, by(region urban year)

sort region  year

by region: gen growth_agg = (logConsAgg - logConsAgg[_n-1])

save "$temp/growthConsurban.dta", replace
