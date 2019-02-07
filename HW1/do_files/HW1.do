//Development HW1
/**
Created by: Alba Miñano Mañero
Date: January 2019
Purpose: HW1 Question 1
*/


clear all
set type double
set more off
	

	global mpath "/Users/albaminano/Dropbox/Development/HW1"
	global path "$mpath"
	gl temp "$path/temp"
	gl data "$path/data"
	gl do "$path/do_files"
	gl output "$path/output"
/* Load consumption data*/
 
 use "$data/UNPS 2013-14 Consumption Aggregate.dta", clear
 
 gen consumption = (cpexp30)*12/hsize // yearly consumption
 gen cons_hh = cpexp30*12
 keep HHID district_code urban ea region regurb consumption wgt_X hsize cons_hh
 
 rename HHID hh
 merge m:1 hh using "$temp/wealth.dta"
 
 drop _merge
 
 
 
  //** Merge with HH roster to get household head, age, education
 rename hh HHID
 merge m:m HHID using "$data/GSEC2.dta"
 
 keep if h2q4 == 1 
 rename h2q8 age 
 rename h2q3 sex
 keep  HHID  PID district_code cons_hh urban ea region regurb consumption wgt_X hsize wealth age sex h2q4
 

 
 merge 1:1 HHID PID using "$data/GSEC4.dta"
 drop _merge
 keep if h2q4 == 1 
 rename h4q7 education
 
 keep HHID district_code urban cons_hh ea region regurb consumption wgt_X hsize wealth age sex education
 

 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID
 
 merge  m:1 HHID using "$temp/income.dta"
 
 drop if consumption ==.
 drop if income == 0
 
 *drop if consumption > wealth+income
 
 drop _merge

 
 /******************** Homework 1 excercises *************/
 
 
 // Convert to 2019 USD 
 
 foreach var in consumption wealth income cons_hh {
 replace `var' = `var'/3700
 }
 
 //Exchange rate in  22nd january 2019 to usd


 save "$temp/question1.dta", replace
 

 // Question 1
 // 1a: average CIW for rural and urban areas

 // drop outliers
 sort income
 drop if HHID == 336030401 // This guy reported an enormous income for his consumption and wealth
 drop if HHID == 100090401
 drop if HHID == 331080401
 drop if HHID == 297100402
 
 
 sort wealth
 drop if HHID == 12090403
 drop if HHID == 363060401
 drop if HHID == 12090401
 drop if HHID == 220020401
 
 sort consumption
 drop if HHID == 233010401
 drop if HHID == 373090401
 drop if HHID == 16040401
 drop if HHID == 48040401
 
// Per HH levels
mean cons_hh [pw=wgt_X] // mean annual cons is 740.16 
mean cons_hh[pw=wgt_X] if urban==0 // Mean annual consumption in rural areas is 640.92 
mean cons_hh[pw=wgt_X] if urban ==1 // Mean annul consumption in rural areas is   1044.38
mean income[pw=wgt_X] // mean income  1485
mean income [pw=wgt_X] if urban==0 // Mean annual income in rural areas is   1073.422    
mean income [pw=wgt_X] if urban ==1 // Mean annul income in urabn areas is    2746.722 
mean wealth [pw=wgt_X] // 2517.757
mean wealth [pw=wgt_X] if urban==0 // Mean annual wealth in rural areas is   1661.28 
mean wealth [pw=wgt_X] if urban ==1 // Mean annual wealth in urban areas is  5143.333  


 
// Per capita levels
 foreach var in wealth income {
 replace `var' = `var'/hsize
 }
  
  save "$temp/question1.dta", replace
 
 mean consumption[pw=wgt_X] //  182.4529
mean income[pw=wgt_X] // 374.891 
mean wealth[pw =wgt_X] //  595.8125 
mean consumption[pw=wgt_X] if urban==0 // Mean annual consumption in rural areas is 153.3254 
mean consumption[pw=wgt_X] if urban ==1 // Mean annul consumption in rural areas is   271.74 
mean income [pw=wgt_X] if urban==0 // Mean annual income in rural areas is   236  
mean income [pw=wgt_X] if urban ==1 // Mean annul income in urabn areas is    800.73  
mean wealth [pw=wgt_X] if urban==0 // Mean annual wealth in rural areas is      373.48   
mean wealth [pw=wgt_X] if urban ==1 // Mean annual wealth in urban areas is  1277.38 



// The results for wealth and income in urban areas are so big because I have two outliers 
* Histograms  
foreach var in consumption wealth income{
 replace `var' = log(`var')
 }
/* 
_pctile consumption, nq(100)
drop if consumption >r(r99) 
_pctile wealth, nq(100)
drop if wealth >r(r99) 
_pctile income, nq(100)
drop if income >r(r99) 
*/
twoway (histogram consumption if urban==0, fcolor(none) lcolor(black)) ///
(histogram consumption if urban==1, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
graphregion(color(white))
graph export "$output/Hist_1a.png", width(1080) as(png) replace

twoway (histogram income if urban==0, fcolor(none) lcolor(black)) ///
(histogram income if urban==1, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
graphregion(color(white))
graph export "$output/Hist_1b.png", width(1080) as(png) replace

 
 twoway (histogram wealth if urban==0, fcolor(none) lcolor(black)) ///
(histogram wealth if urban==1, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
graphregion(color(white))
graph export "$output/Hist_1c.png", width(1080) as(png) replace

 
 * Variance of logs 
use "$temp/question1.dta", clear 
 sort income
 drop if HHID == 336030401 // This guy reported an enormous income for his consumption and wealth
 drop if HHID == 100090401
 drop if HHID == 331080401
 drop if HHID == 297100402
 
 
 sort wealth
 drop if HHID == 12090403
 drop if HHID == 363060401
 drop if HHID == 12090401
 drop if HHID == 220020401
 
 sort consumption
 drop if HHID == 233010401
 drop if HHID == 373090401
 drop if HHID == 16040401
 drop if HHID == 48040401
foreach var in consumption wealth income {

 gen log_`var'=log(`var')
 gen log_`var'_mean=.
 gen vl_`var'=.
 }

 foreach var in consumption wealth income{
 sum log_`var' [w=wgt_X]
 replace log_`var'_mean = r(mean)
 replace vl_`var'=(log_`var'-log_`var'_mean)^2
 mean vl_`var' [pw=wgt_X] if urban== 0
 mean vl_`var' [pw=wgt_X] if urban== 1
 }

 mean vl_consumption [pw=wgt_X] // .5454707 
 mean vl_income [pw=wgt_X] //  2.598067
 mean vl_wealth [pw=wgt_X] // 2.468685
 
 mean vl_consumption [pw=wgt_X] if urban== 0 // 0.4640306 
 mean vl_consumption [pw=wgt_X] if urban== 1 //  .7951298 
 mean vl_income [pw=wgt_X] if urban== 0 //  2.29
 mean vl_income [pw=wgt_X] if urban== 1 //  3.52
 mean vl_wealth [pw=wgt_X] if urban== 0 //  1.96
 mean vl_wealth [pw=wgt_X] if urban== 1 // 3.99 
 
 drop log_* vl_*
 // Adding the life cycle
 

gen income_t = .
gen wealth_t = .
gen consumption_t = .

foreach var in income wealth consumption{
 forvalues i=15(1)105 {
 sum `var' [w=wgt_X] if age == `i'
 replace `var'_t = r(mean) if age == `i'
 }
}


 preserve
 keep if age >=20 & age <= 70
 collapse (mean) income_t wealth_t consumption_t, by(age)
 foreach var in income_t wealth_t consumption_t {
replace `var' = log(`var')
}

 graph twoway connected income_t age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Income", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(20(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_1a.png", width(1080) as(png) replace
	
 graph twoway connected wealth_t age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Wealth", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(20(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_1b.png", width(1080)replace
	
graph twoway connected consumption_t age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Consumption", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(20(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_1c.png", width(1080)replace

restore

// Variance of log earnings along the lifecycle
keep if  age >=20 & age <70
foreach var in consumption wealth income {

 gen log_`var'=log(`var')
 gen log_`var'_mean=.
 gen vl_`var'=.
 gen vl_`var'_all =.
 }


 forvalues i=15(1)70{
 sum log_consumption [w=wgt_X] if age == `i'
 replace log_consumption_mean = r(mean) if age == `i'
 replace vl_consumption=(log_consumption-log_consumption_mean)^2 if age == `i'
 
  sum log_income [w=wgt_X] if age == `i'
 replace log_income_mean = r(mean) if age == `i'
 replace vl_income=(log_income-log_income_mean)^2 if age == `i'
 
 sum log_wealth [w=wgt_X] if age == `i'
 replace log_wealth_mean = r(mean) if age == `i'
 replace vl_wealth=(log_income-log_income_mean)^2 if age == `i'
 
  
 }
 

foreach var in consumption wealth income{
  forvalues i=15(1)70 {
 sum vl_`var' [w=wgt_X] if age == `i'
 replace vl_`var'_all = r(mean) if age == `i'
 }
}
preserve 
collapse (mean) vl_* , by(age)
 graph twoway connected vl_consumption_all age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Variance of log consumption", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(20(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_3a.png", width(1080)replace


 graph twoway connected vl_income_all age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Variance of log income", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(20(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_3b.png", width(1080)replace

 graph twoway connected vl_wealth_all age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Variance of log wealth", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(20(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_3c.png", width(1080)replace
restore


 //** Top and bottom**//
 use "$temp/question1.dta", replace 

 * Get percentiles and quantiles
xtile percentile = income, n(100) 
xtile quantile = income, n(5)

egen const = sum(consumption)
bysort percentile: egen consumption_total_p = sum(consumption)
bysort quantile: egen consumption_total_qt = sum(consumption)
gen cons_to_total = consumption_total_p/const
gen cons_to_totalq =consumption_total_qt/const


//Wealth
egen wealtht= sum(wealth)
bysort percentile: egen wealth_total_p = sum(wealth)
bysort quantile: egen  wealth_total_qt = sum(wealth)
gen wealth_to_total  = wealth_total_p/wealtht
gen wealth_to_totalq = wealth_total_qt/wealtht

tab percentile cons_to_total if percentile<5
tab percentile cons_to_total if percentile>95

tab quantile cons_to_totalq
/*
         5 |
 quantiles |                     cons_to_totalq
 of income |  .1082034   .1156995   .1446293   .2029103   .4285576 |     Total
*/


tab percentile wealth_to_total if percentile <5
tab percentile wealth_to_total if percentile >95
tab quantile wealth_to_totalq
/*
       5 |
 quantiles |                    wealth_to_totalq
 of income |  .0602393   .0646195     .11301   .1951665   .5669648 |     Total

 */

//Variances covariances 
 drop if HHID == 336030401 // This guy reported an enormous income for his consumption and wealth
 drop if HHID == 100090401
 drop if HHID == 331080401
 drop if HHID == 297100402
 
 
 sort wealth
 drop if HHID == 12090403
 drop if HHID == 363060401
 drop if HHID == 12090401
 drop if HHID == 220020401
 
 sort consumption
 drop if HHID == 233010401
 drop if HHID == 373090401
 drop if HHID == 16040401
 drop if HHID == 48040401

 foreach var in consumption wealth income{
 replace `var' = log(`var')
 }
 
 correlate consumption wealth income
 /*
             | consum~n   wealth   income
-------------+---------------------------
 consumption |   1.0000
      wealth |   0.5777   1.0000
      income |   0.6195   0.4703   1.0000

*/

correlate consumption wealth income if urban == 0
/*

             | consum~n   wealth   income
-------------+---------------------------
 consumption |   1.0000
      wealth |   0.5352   1.0000
      income |   0.5140   0.4178   1.0000



*/

correlate consumption wealth income if urban == 1

/*
             | consum~n   wealth   income
-------------+---------------------------
 consumption |   1.0000
      wealth |   0.5609   1.0000
      income |   0.6741   0.4547   1.0000


*/

keep if age >=20 & age <70
correlate consumption wealth income age
/*

             | consum~n   wealth   income      age
-------------+------------------------------------
 consumption |   1.0000
      wealth |   0.5772   1.0000
      income |   0.6302   0.4743   1.0000
         age |  -0.0166   0.1512  -0.1108   1.0000



*/

correlate consumption wealth income age if urban == 0
/*
             | consum~n   wealth   income      age
-------------+------------------------------------
 consumption |   1.0000
      wealth |   0.5319   1.0000
      income |   0.5226   0.4147   1.0000
         age |   0.0639   0.1617  -0.0827   1.0000


*/

correlate consumption wealth income age if urban == 1

/*
             | consum~n   wealth   income      age
-------------+------------------------------------
 consumption |   1.0000
      wealth |   0.5581   1.0000
      income |   0.6777   0.4651   1.0000
         age |  -0.0941   0.2134  -0.1075   1.0000



*/



