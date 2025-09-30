ssc install csdid 
ssc install drdid

use min_wage_cs, clear
//use rif1, clear - check data for merging

* merge data
merge m:1 countyreal using rif1.dta

* treatment year dummy variable
gen treat_year = .
replace treat_year = (first_treat==year)

* post treatment dummy variable
gen post = .
replace post = (year>=first_treat)

* reg as panel data
xtset countyreal year

* two way fixed effects model
eststo: xtreg lemp post i.year, fe cluster(countyreal)
esttab using twfe.tex

di _b[post]

csdid lemp, ivar(countyreal) time(year) gvar(first_treat)

csdid_plot, group(2007) title("Group 2007") xsize(10) ysize(5) ylabel(-0.2(.1)0.2) ytitle() xtitle() legend(off) xlabel(-5 "2002" -4 "2003" -3 "2004"   -2 "2005" -1 "2006" 0 "2007")

graph export figure1.png
