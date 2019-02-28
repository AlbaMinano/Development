//Development HW3
/**
Created by: Alba Miñano Mañero
Date: February 2019
Purpose: HW3 urban
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

keep if urban == 1
drop if ctotal==0 | ctotal==.
drop if inctotal==0 |inctotal==.

generate log_c=log(ctotal)
generate log_income = log(inctotal)
gen rural = 1-urban
gen res_c = . 

replace year = 2009 if wave =="2009-2010"
replace year = 2010 if wave == "2010-2011"

xtset hh year

 // Drop observations that appear only one year 
 drop if counthh <= 2

// Regress and get residuals of consumption

xi: reg log_c age age_sq i.year familysize  i.female i.ethnic  i.rural
predict res, res

xi: reg log_income age age_sq i.year familysize  i.female i.ethnic  i.rural
predict res_inc, res

drop _I*


//Need to balance the panel
gen dummy = 0
replace dummy = 1 if year == 2010
replace dummy = 2 if year == 2011
replace dummy = 3 if year == 2012
replace dummy = 4 if year == 2013
replace dummy = 5 if year == 2014

sort hh year
by hh: gen dyear = dummy - dummy[_n-1]
by hh: gen growth = (res - res[_n-1])
by hh: gen growth_inc= (res_inc - res_inc[_n-1])


// Annualize the growth rates if there are missing observations 
bysort hh: replace growth = growth *(1/2) if dyear == 2
bysort hh: replace growth = growth *(1/3) if dyear == 3
bysort hh: replace growth = growth *(1/4) if dyear == 4
bysort hh: replace growth = growth *(1/5) if dyear == 5

bysort hh: replace growth_inc = growth_inc *(1/2) if dyear == 2
bysort hh: replace growth_inc = growth_inc *(1/3) if dyear == 3
bysort hh: replace growth_inc = growth_inc *(1/4) if dyear == 4
bysort hh: replace growth_inc = growth_inc *(1/5) if dyear == 5

// Obtain average consumption
merge m:1 region year using "$temp/growthConsurban.dta"
keep if _merge == 3
drop _merge

keep region year urban hh logConsAgg inctotal growth growth_inc  rural growth_agg

save "$temp/datacleanurban.dta", replace 
statsby _b, by(hh) saving("$temp/q1urban.dta", replace):  reg growth growth_inc growth_agg, nocons vce(robust)

use "$temp/q1urban.dta", clear

egen ptile =xtile(_b_growth_inc), nq(100)
drop if ptile==1
drop if ptile==100

egen ptilephi =xtile(_b_growth_agg), nq(100)
drop if ptilephi==1
drop if ptilephi==100


sum _b_growth_inc, detail
sum _b_growth_agg, detail

twoway (histogram _b_growth_inc if _b_growth_inc >=-6 & _b_growth_inc<=6, bin(50) fcolor(none) lcolor(black)), ///
xtitle("Beta", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/Q1Aurban.png", width(1080) as(png) replace

twoway (histogram  _b_growth_agg if  _b_growth_agg>=-6&  _b_growth_agg<=6, bin(50)  fcolor(none) lcolor(black)), ///
xtitle("Phi", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/Q1A_2urban.png", width(1080) as(png) replace


/****************+
Question 2
*****************/

use "$temp/datacleanurban.dta", clear

xtset hh year

// Compute av income
by hh, sort: egen AvIncome =mean(inctotal)

*ssc install egenmore


collapse (mean) AvIncome, by(hh)


// Merge with betas and phis

merge 1:1 hh using "$temp/q1urban.dta",
drop _merge

drop if _b_growth_inc ==. 
drop if _b_growth_agg==. 



//Obtain income quantiles 
egen quintile = xtile(AvIncome), nq(5)


egen ptile =xtile(_b_growth_inc), nq(100)
drop if ptile==1
drop if ptile==100



// HIstogram of betas depending on quintile

twoway (histogram _b_growth_inc if quintile==1 & _b_growth_inc >=-6 & _b_growth_inc<=6, bin(50) fcolor(none) lcolor(black)) ///
(histogram _b_growth_inc if quintile==2 & _b_growth_inc >=-6 & _b_growth_inc<=6, bin(50) fcolor(none) lcolor(blue)) ///
(histogram _b_growth_inc if quintile==3 & _b_growth_inc >=-6 & _b_growth_inc<=6, bin(50) fcolor(none) lcolor(red)) ///
(histogram _b_growth_inc if quintile==4 & _b_growth_inc >=-6 & _b_growth_inc<=6, bin(50) fcolor(none) lcolor(green)) ///
(histogram _b_growth_inc if quintile==5 & _b_growth_inc >=-6 & _b_growth_inc<=6, bin(50) fcolor(none) lcolor(yellow)), ///
legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5")) ///
xtitle("Beta", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/Q2aurban.png", width(1080) as(png) replace


sum _b_growth_inc if quintile==1, detail
sum _b_growth_inc if quintile==2, detail
sum _b_growth_inc if quintile==3, detail
sum _b_growth_inc if quintile==4, detail
sum _b_growth_inc if quintile==5, detail




// PART C 


 
use "$temp/q1urban.dta", clear 

drop if _b_growth_inc ==.
drop if _b_growth_agg ==.

egen ptile =xtile(_b_growth_inc), nq(100)
drop if ptile==1
drop if ptile==100



egen quintile = xtile(_b_growth_inc), nq(5)

merge 1:m hh using "$temp/datacleanurban.dta"
keep if _merge == 3


by quintile, sort: egen QuintIncome =mean(inctotal)

gen loginctotal=log(inctotal)
sum loginctotal if quintile==1, detail
sum loginctotal if quintile==2, detail
sum loginctotal if quintile==3, detail
sum loginctotal if quintile==4, detail
sum loginctotal if quintile==5, detail

/************************
Question 3
*************************/
 use "$temp/datacleanurban.dta", replace
 

label var growth_inc "$\beta$"
label var growth_agg "$\phi$"
xi: reg growth growth_inc growth_agg, nocons 

outreg2 using "$output/Table1a.tex", tex append ctitle( "$\triangle$" "($\log$)" "$\c_{it}$")/*
*/nocons keep(growth_inc growth_agg) see label adjr2 addtext(Sample, Urban)


