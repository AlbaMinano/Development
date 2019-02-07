//Development HW1
/**
Created by: Alba Miñano Mañero
Date: January 2019
Purpose: HW1 Question 2 
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
	
//// Question 2

 /// This is only computed for household heads
 
 use "$temp/labor_supply.dta", clear
 drop _merge
keep if age> 15 & age < 70
mean ls_total [pw=wgt_X]  // 37 2,843
mean ls_total [pw=wgt_X] if urban==0 // Mean weekly hours worked is 36.87472 for rural areas 2, 088
mean ls_total [pw=wgt_X] if urban ==1 // Mean weekly hours worked is 38.82914 for urban areas  755

bysort urban: egen emp=sum(wgt_X) if ls_total>0
bysort urban: egen total=sum(wgt_X) 
gen extensive = emp/total

mean extensive [pw=wgt_X] // 0.96
mean extensive [pw=wgt_X] if urban == 0 // 0.97
mean extensive [pw=wgt_X] if urban == 1 // 0.91
// Extesnive margin in rural areas is .9746763 % ( of HH) 
// Extensive margin in urban areas is .915341 %  (of HH) 
// Total sum of weights (only >15 years old) 5747602.2
// Of total population ( older than 15) extensive margin is 83% in rural
// Of total population ( older than 15) extensive margin is 26% in urban areas 

preserve
replace ls_total=log(ls_total)
twoway (histogram ls_total if urban==0, fcolor(none) lcolor(black)) ///
(histogram ls_total if urban==1, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
ytitle("Log(Weekly Hours)", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/LS_1a.png", width(1080) as(png) replace
restore

 * Variance of logs 

foreach var in ls_total{

 gen log_`var'=log(`var')
 gen log_`var'_mean=.
 gen vl_`var'=.
 }

 foreach var in ls_total{
 sum log_`var' [w=wgt_X]
 replace log_`var'_mean = r(mean)
 replace vl_`var'=(log_`var'-log_`var'_mean)^2
 }

 mean vl_ls_total [pw= wgt_X]  //  0. 44
 mean vl_ls_total [pw=wgt_X] if urban== 0 // .4446435 
 mean vl_ls_total [pw=wgt_X] if urban== 1 //  .4633767 
 
 preserve

 collapse (mean) ls_total vl_ls_total, by(age)
 graph twoway connected ls_total age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Weekly Hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(15(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_2a.png", width(1080) as(png) replace
	
 graph twoway connected vl_ls_total age, ///
	lp(solid) lw(thick) lc("255 77 77") mc("255 77 77")  ///
	, ytitle("Var of Log Weekly Hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(15(10)70,  labsize(medlarge) noticks grid angle(45)) ///
	graphregion(color(white))
	graph export "$output/Fig_2b.png", width(1080) as(png) replace
restore		
 // To rank HHH by data, we merge with question  1 data
 
merge m:m HHID using "$temp/question1.dta" // the observations we loose is because they < 15 or >105
drop if _merge == 2
drop _merge 


 sort income
 gen ww =.
 replace ww=round(wgt_X)
 gen w =sum(wgt_X)
 preserve
 drop if w>57475 // Bottom 1 %
 replace ls_total = log(ls_total)
 histogram ls_total 

 restore
 preserve
 drop if w < 5690083 // top 1%
replace ls_total = log(ls_total)	
 histogram ls_total
 restore
 
 
 /*****************************************************************************
 *****************************************************************************/
 
 // Redo for wormen (2) / men (1)
 
 //Men 
 mean ls_total [pw=wgt_X] if sex == 1 // 38  1977
mean ls_total [pw=wgt_X] if urban==0 & sex ==1 // Mean weekly hours worked is 37 for rural areas 1454
mean ls_total [pw=wgt_X] if urban ==1  & sex == 1 // Mean weekly hours worked is   41.36445 for urban areas  523


//Women 
mean ls_total [pw= wgt_X] if sex == 2 // 34 866
mean ls_total [pw=wgt_X] if urban==0 & sex ==2 // Mean weekly hours worked is 34.9 for rural areas 634
mean ls_total [pw=wgt_X] if urban ==1  & sex == 2 // Mean weekly hours worked is 33.4 for urban areas  232

preserve
replace ls_total=log(ls_total)

twoway (histogram ls_total if urban==0 & sex ==1, fcolor(none) lcolor(black)) ///
(histogram ls_total if urban==1 & sex == 1, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
ytitle("Log(Weekly Hours)", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/LS_2a_m.png", width(1080) as(png) replace

twoway (histogram ls_total if urban==0 & sex ==2, fcolor(none) lcolor(black)) ///
(histogram ls_total if urban==1 & sex == 2, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
ytitle("Log(Weekly Hours)", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/LS_2a_w.png", width(1080) as(png) replace

restore
 * Variance of logs 
forvalues  i=1(1)2{
foreach var in ls_total{

 gen log_`var'_`i'=log(`var') if sex == `i'
 gen log_`var'_mean_`i'=. if sex == `i'
 gen vl_`var'_`i'=. if sex == `i'
 }
}
forvalues i=1(1)2{
 foreach var in ls_total{
 sum log_`var'_`i' [w=wgt_X] if sex == `i'
 replace log_`var'_mean_`i' = r(mean) if sex == `i'
 replace vl_`var'_`i'=(log_`var'_`i'-log_`var'_mean_`i')^2 if sex == `i'
 }
}

//Men
mean vl_ls_total_1 [pw= wgt_X] // 0.4
 mean vl_ls_total_1 [pw=wgt_X] if urban== 0 & sex ==1 // .40
 mean vl_ls_total_1 [pw=wgt_X] if urban== 1  & sex ==1 //  .3916352  

 //Women
 mean vl_ls_total_2 [pw= wgt_X] // 0.54 
 mean vl_ls_total_2 [pw=wgt_X] if urban== 0 & sex ==2 // .5200424 
 mean vl_ls_total_2 [pw=wgt_X] if urban== 1  & sex ==2 //   .618639  
 
 preserve

 collapse (mean) ls_total vl_ls_total_1 vl_ls_total_2, by(age sex)
 

graph twoway (connected ls_total age if sex==1, lp(solid) lw(thick) lc("255 204 153") mc("255 204 153")) ///
(connected ls_total age if sex==2, lp(solid) lw(thick) lc("204 153 51") mc("204 153 51")) ///
, ytitle("Weekly Hours", size(medlarge)) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(15(10)70, noticks grid) ///
	  legend( ///
		 ring(1) ///
		 lab(1 "Men") lab(2 "Women") ////
		 size(medium) ///
		 stack ///
		 region(style(none) lcolor(none)) ///
		 rows(1)  ///
		 position(11) ///
		 keygap(-.1) ///
		) ///
	graphregion(color(white))
	graph export "$output/Fig_3a_LS.png", width(1080)replace	
	
graph twoway (connected vl_ls_total_1 age if sex==1, lp(solid) lw(thick) lc("255 204 153") mc("255 204 153")) ///
(connected vl_ls_total_2 age if sex==2, lp(solid) lw(thick) lc("204 153 51") mc("204 153 51")) ///
, ytitle("Var(Log Weekly Hours)", size(medlarge)) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(15(10)70, noticks grid) ///
	  legend( ///
		 ring(1) ///
		 lab(1 "Men") lab(2 "Women") ////
		 size(medium) ///
		 stack ///
		 region(style(none) lcolor(none)) ///
		 rows(1)  ///
		 position(11) ///
		 keygap(-.1) ///
		) ///
	graphregion(color(white))
	graph export "$output/Fig_3b_LS.png", width(1080)replace	
	
		
restore

/******************************************************************************
******************************************************************************/

// By education groups 
drop if education ==. 
gen edc =.
replace edc = 1 if education < 17 // less than P.7
replace edc = 2 if education == 17 & education < 34 //Primary education but less than High school
replace edc = 3 if education >=34 // Secondaary and more

 
// Less than PR school
mean ls_total [pw=wgt_X] if edc ==1  // 37.56333  1,008
mean ls_total [pw=wgt_X] if urban==0 & edc==1 // Mean weekly hours worked is 37 for rural areas 844
mean ls_total [pw=wgt_X] if urban ==1  & edc == 1 // Mean weekly hours worked is   38.63954   for urban areas  164


// Primary but less than secondary

mean ls_total [pw=wgt_X]if edc == 2 // 39 422
mean ls_total [pw=wgt_X] if urban==0 & edc ==2 // Mean weekly hours worked is 38.32 for rural areas 322
mean ls_total [pw=wgt_X] if urban ==1  & edc == 2 // Mean weekly hours worked is  41.83 for urban areas  100

// Secondary and more
mean ls_total [pw=wgt_X] if edc ==3 // 39.4 616
mean ls_total [pw=wgt_X] if urban==0 & edc ==3 // Mean weekly hours worked is 38.38 for rural areas 316
mean ls_total [pw=wgt_X] if urban ==1  & edc == 3 // Mean weekly hours worked is  40 for urban areas  300

preserve
replace ls_total=log(ls_total)

twoway (histogram ls_total if urban==0 & edc ==1, fcolor(none) lcolor(black)) ///
(histogram ls_total if urban==1 & edc == 1, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
ytitle("Log(Weekly Hours)", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/LS_3a_lessprimary.png", width(1080) as(png) replace

twoway (histogram ls_total if urban==0 & edc ==2, fcolor(none) lcolor(black)) ///
(histogram ls_total if urban==1 & edc == 2, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
ytitle("Log(Weekly Hours)", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/LS_3a_hs.png", width(1080) as(png) replace

twoway (histogram ls_total if urban==0 & edc ==3, fcolor(none) lcolor(black)) ///
(histogram ls_total if urban==1 & edc == 3, fcolor(none) lcolor(blue)), ///
legend(order(1 "Rural" 2 "Urban")) ///
ytitle("Log(Weekly Hours)", size(medlarge)) ///
graphregion(color(white)) 
graph export "$output/LS_3a_morehs.png", width(1080) as(png) replace
restore

drop log_* vl_*
 * Variance of logs 
forvalues  i=1(1)3{
foreach var in ls_total{

 gen log_`var'_`i'=log(`var') if edc == `i'
 gen log_`var'_mean_`i'=. if edc == `i'
 gen vl_`var'_`i'=. if edc== `i'
 }
}
forvalues i=1(1)3{
 foreach var in ls_total{
 sum log_`var'_`i' [w=wgt_X] if edc == `i'
 replace log_`var'_mean_`i' = r(mean) if edc == `i'
 replace vl_`var'_`i'=(log_`var'_`i'-log_`var'_mean_`i')^2 if edc== `i'
 }
}

//Less than primary
mean vl_ls_total_1 [pw=wgt_X] // 0.42 
 mean vl_ls_total_1 [pw=wgt_X] if urban== 0 & edc==1 // .41
 mean vl_ls_total_1 [pw=wgt_X] if urban== 1  & edc ==1 //  .472  

 //Primary but less than secondary
 mean vl_ls_total_2 [pw=wgt_X]  // 0.38
 mean vl_ls_total_2 [pw=wgt_X] if urban== 0 & edc ==2 // .37
 mean vl_ls_total_2 [pw=wgt_X] if urban== 1  & edc ==2 //   .4342 

  //Primary but less than secondary
  mean vl_ls_total_2 [pw=wgt_X]  // 0.38
 mean vl_ls_total_3 [pw=wgt_X] if urban== 0 & edc ==3 // .36
 mean vl_ls_total_3 [pw=wgt_X] if urban== 1  & edc ==3 //   .37  
 
 preserve

 collapse (mean) ls_total vl_ls_total_1 vl_ls_total_2 vl_ls_total_3, by(age edc)
 
graph twoway (connected ls_total age if edc==1, lp(solid) lw(thick) lc("255 204 153") mc("255 204 153")) ///
(connected ls_total age if edc==2, lp(solid) lw(thick) lc("204 153 51") mc("204 153 51")) ///
(connected ls_total age if edc==3, lp(solid) lw(thick) lc("100 153 51") mc("230 150 51")) ///
, ytitle("Weekly Hours", size(medlarge)) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(15(10)70, noticks grid) ///
	  legend( ///
		 ring(1) ///
		 lab(1 "Less than Primary") lab(2 "Less than High School") lab(3 "High School and more") ////
		 size(medium) ///
		 stack ///
		 region(style(none) lcolor(none)) ///
		 rows(1)  ///
		 position(11) ///
		 keygap(-.1) ///
		) ///
	graphregion(color(white))
	graph export "$output/Fig_3c_LS.png", width(1080)replace	
	
graph twoway (connected vl_ls_total_1 age if edc==1, lp(solid) lw(thick) lc("255 204 153") mc("255 204 153")) ///
(connected vl_ls_total_2 age if edc==2, lp(solid) lw(thick) lc("204 153 51") mc("204 153 51")) ///
(connected vl_ls_total_3 age if edc==3, lp(solid) lw(thick) lc("100 153 51") mc("230 150 51")) ///
, ytitle("Var(Log Weekly Hours)", size(medlarge)) ///
	 xtitle("Age", size(medlarge)) ///
	 xlabel(15(10)70, noticks grid) ///
	  legend( ///
		 ring(1) ///
		 lab(1 "Less than Primary") lab(2 "Less than High School") lab(3 "High School and more") ////
		 size(medium) ///
		 stack ///
		 region(style(none) lcolor(none)) ///
		 rows(1)  ///
		 position(11) ///
		 keygap(-.1) ///
		) ///
	graphregion(color(white))
	graph export "$output/Fig_3d_LS.png", width(1080)replace	
	
		
restore

//Correlations 
foreach var in ls_total consumption income wealth {
replace `var' = log(`var')
}
correlate ls_total consumption income wealth age
/*

             | ls_total consum~n   income   wealth      age
-------------+---------------------------------------------
    ls_total |   1.0000
 consumption |   0.1712   1.0000
      income |   0.2599   0.6444   1.0000
      wealth |   0.1235   0.5635   0.4864   1.0000
         age |  -0.0610   0.0100  -0.0729   0.1837   1.0000



*/
correlate ls_total consumption income wealth age if urban == 0

/*
             | ls_total consum~n   income   wealth      age
-------------+---------------------------------------------
    ls_total |   1.0000
 consumption |   0.1676   1.0000
      income |   0.2610   0.5385   1.0000
      wealth |   0.1673   0.5143   0.4288   1.0000
         age |  -0.0303   0.0834  -0.0552   0.1910   1.0000



*/

correlate ls_total consumption income wealth age if urban == 1
/*


             | ls_total consum~n   income   wealth      age
-------------+---------------------------------------------
    ls_total |   1.0000
 consumption |   0.0860   1.0000
      income |   0.1944   0.6817   1.0000
      wealth |  -0.0242   0.5559   0.4790   1.0000
         age |  -0.1231  -0.0484  -0.0460   0.2422   1.0000



*/
