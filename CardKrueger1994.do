infix using codebook.dct

*process date variable
gen date2 = date(DATE2, "MD19Y")
format date2 %td
drop DATE2
rename date2 DATE2
order DATE2, after(STATUS2)

* assign variable labels
label variable SHEET "sheet number (unique store id)"
label variable CHAIN "chain 1=bk; 2=kfc; 3=roys; 4=wendys"
label variable CO_OWNED "1 if company owned"
label variable STATE "1 if NJ; 0 if Pa"
*Dummies for location:
label variable SOUTHJ "1 if in southern NJ"
label variable CENTRALJ "1 if in central NJ"
label variable NORTHJ "1 if in northern NJ"
label variable PA1 "1 if in PA, northeast suburbs of Phila"
label variable PA2 "1 if in PA, Easton etc"
label variable SHORE "1 if on NJ shore"
*First Interview
label variable NCALLS "number of call-backs*"
label variable EMPFT "# full-time employees"
label variable EMPPT "# part-time employees"
label variable NMGRS "# managers/ass't managers"
label variable WAGE_ST "starting wage ($/hr)"
label variable INCTIME "months to usual first raise"
label variable FIRSTINC "usual amount of first raise ($/hr)"
label variable BONUS "1 if cash bounty for new workers"
label variable PCTAFF "% employees affected by new minimum"
label variable MEALS "free/reduced price code (See below)"
label variable OPEN "hour of opening"
label variable HRSOPEN "number hrs open per day"
label variable PSODA "price of medium soda, including tax"
label variable PFRY "price of small fries, including tax"
label variable PENTREE "price of entree, including tax"
label variable NREGS "number of cash registers in store"
label variable NREGS11 "number of registers open at 11:00 am"
*Second Interview
label variable TYPE2 "type 2nd interview 1=phone; 2=personal"
label variable STATUS2 "status of second interview: see below"
label variable DATE2 "date of second interview MMDDYY format"
label variable NCALLS2 "number of call-backs*"
label variable EMPFT2 "# full-time employees"
label variable EMPPT2 "# part-time employees"
label variable NMGRS2 "# managers/ass't managers"
label variable WAGE_ST2 "starting wage ($/hr)"
label variable INCTIME2 "months to usual first raise"
label variable FIRSTIN2 "usual amount of first raise ($/hr)"
label variable SPECIAL2 "1 if special program for new workers"
label variable MEALS2 "free/reduced price code (See below)"
label variable OPEN2R "hour of opening"
label variable HRSOPEN2 "number hrs open per day"
label variable PSODA2 "price of medium soda, including tax"
label variable PFRY2 "price of small fries, including tax"
label variable PENTREE2 "price of entree, including tax"
label variable NREGS2 "number of cash registers in store"
label variable NREGS112 "number of registers open at 11:00 am"

save cardnj, replace

///use cardnj, clear


gen pct_full_time = (EMPFT / EMPFT + EMPPT) // percentage full time
gen FTE = NMGRS + EMPFT + (0.5 * EMPPT) // full-time-equivalent [FTE] employment
gen PMEAL = PSODA + PFRY + PENTREE // meal price
gen wage_425 = (WAGE_ST == 4.25) // indicator if wages = 4.25

gen pct_full_time2 = (EMPFT2 / EMPFT2 + EMPPT2) // percentage full time
gen FTE2 = NMGRS2 + EMPFT2 + (0.5 * EMPPT2) // full-time-equivalent [FTE] employment
gen PMEAL2 = PSODA2 + PFRY2 + PENTREE2 // meal price
gen wage2_425 = (WAGE_ST2 == 4.25) // indicator if wages = 4.25
gen wage_5 = (WAGE_ST2 < 5.06 & WAGE_ST2 > 5.04) // indicator if wages = 4.25

gen bk= 0
gen kfc= 0
gen roys= 0
gen wendys= 0

replace bk = 1 if CHAIN==1
replace kfc = 1 if CHAIN==2
replace roys = 1 if CHAIN==3
replace wendys = 1 if CHAIN==4


///-------------------------/// TABLE 2 ///-------------------------///

* Distribution of Store Types (percentages) *
tabulate CHAIN STATE, col nofreq

tabulate CHAIN STATE, col nofreq matcell(C)
mat list C
matrix denoms = J(1, 4, 1)*C
matrix list denoms
forvalues c = 1/2 {
	forvalues r = 1/4 {
		matrix C[`r', `c'] = 100*C[`r', `c']/denoms[1, `c']
		}
		}
matrix list C

* T stat *
quietly prtesti 331 .4109 79 .4430
di r(z)
quietly prtesti 331 .2054 79 .1519
di r(z)
quietly prtesti 331 .2477 79 .2152
di r(z)
quietly prtesti 331 .1360 79 .1899
di r(z)

ci means bk kfc roys wendys CO_OWNED ///
FTE pct_full_time WAGE_ST wage_425 PMEAL HRSOPEN BONUS ///
FTE2 pct_full_time2 WAGE_ST2 wage2_425 wage_5 PMEAL2 HRSOPEN2 SPECIAL2  ///
if STATE==1

ci means bk kfc roys wendys CO_OWNED ///
FTE pct_full_time WAGE_ST wage_425 PMEAL HRSOPEN BONUS ///
FTE2 pct_full_time2 WAGE_ST2 wage2_425 wage_5 PMEAL2 HRSOPEN2 SPECIAL2 ///
if STATE==0


* Means in Wave I *
*2a, 2b, 2c, 2e, 2f
bysort STATE: tabstat FTE pct_full_time WAGE_ST wage_425 PMEAL HRSOPEN, statistic(mean semean)
*2d
bysort STATE: sum WAGE_ST if WAGE_ST == 4.25
*2g
tabulate STATE BONUS, row nofreq

* Means in Wave II *
*3a, 3b, 3c, 3f, 3g
bysort STATE: tabstat FTE2 pct_full_time2 WAGE_ST2 wage2_425 wage_5 PMEAL2 HRSOPEN2, statistic(mean semean)

*3h
tabulate STATE BONUS, row

///-------------------------/// FIGURE 1 INTERVIEW 1///-------------------------///

***
//graph bar STATE, over(WAGE_ST)
//graph bar (sum) WAGE_ST, over(STATE, relabel(1 "PA" 2 "NJ"))
***
gen wage_range = floor(WAGE_ST * 10) / 10
gen PERC_NJ = .
gen PERC_PA = .

count if STATE == 1
local count_state1 = r(N)
replace PERC_NJ = 1/`count_state1'*100 if STATE == 1

count if STATE == 0
local count_state0 = r(N)
replace PERC_PA = 1/`count_state0'*100 if STATE == 0

graph bar (percent) PERC_NJ (percent) PERC_PA, ///
over(wage_range, label(angle(0))) ///
title(February 1992) ///
ytitle(Percent of Stores,size(small)) ///
ylabel(0(5)35) ///
legend(off)

graph export figure1.png


gen wage_range2 = floor(WAGE_ST2 * 10) / 10
gen PERC_NJ2 = .
gen PERC_PA2 = .

count if STATE == 1
local count_state1 = r(N)
replace PERC_NJ2 = 1/`count_state1'*100 if STATE == 1

count if STATE == 0
local count_state0 = r(N)
replace PERC_PA2 = 1/`count_state0'*100 if STATE == 0

graph bar (percent) PERC_NJ2 (percent) PERC_PA2, ///
over(wage_range2, label(angle(0))) ///
title(November 1992) ///
ytitle(Percent of Stores,size(small)) ///
ylabel(0(5)90) ///
legend(order(2 "Pennsylvania" 1 "New Jersey"))

graph export figure2.png

///-------------------------/// TABLE 3 ///-------------------------///

*R1C1-3
ttest FTE, by(STATE) unequal
*R1C4
ci means FTE if (STATE == 1) & (wage_425 == 1)
*R1C5
ci means FTE if (STATE == 1) & (WAGE_ST > 4.25 & WAGE_ST < 5)
*R1C6
ci means FTE if (STATE == 1) & (WAGE_ST >=5)

*R2C1-3
ttest FTE2, by(STATE) unequal
*R2C4
ci means FTE2 if (STATE == 1) & (wage_425 == 1)
*R2C5
ci means FTE2 if (STATE == 1) & (WAGE_ST > 4.25 & WAGE_ST < 5)
*R2C6
ci means FTE2 if (STATE == 1) & (WAGE_ST >=5)

*R3C1
ttest FTE2 == FTE if STATE==0, unpaired
*R3C2
ttest FTE2 == FTE if STATE==1, unpaired
*R3C3

*R3C4
ttest FTE2 == FTE if (STATE==1) & (wage_425==1), unpaired
*R3C5
ttest FTE2 == FTE if (STATE==1) & (WAGE_ST > 4.25 & WAGE_ST < 5), unpaired
*R3C6
ttest FTE2 == FTE if (STATE==1) & (WAGE_ST >=5), unpaired


*R4C1
ttest FTE2 == FTE if STATE==0
ttest FTE2 == FTE if STATE==1
*R4C3
*R4C4
ttest FTE2 == FTE if (STATE==1) & (wage_425==1)
*R4C5
ttest FTE2 == FTE if (STATE==1) & (WAGE_ST > 4.25 & WAGE_ST < 5)
*R4C6
ttest FTE2 == FTE if (STATE==1) & (WAGE_ST >=5)



///-------------------------/// TABLE 4 ///-------------------------///

*subset
//drop if EMPFT == . | EMPPT == . | EMPFT2 == . | EMPPT2 == . | NMGRS == . | NMGRS2 == . 
//drop if WAGE_ST == . | WAGE_ST2 == .

gen FTEDIFF = .
replace FTEDIFF = FTE2-FTE

*same results if adding subset of stores without missing observations
//gen subset = 0
//replace subset = 1 if (FTEDIFF!=.) | (WAGE_ST!=.) | (WAGE_ST2!=.)
//sum FTEDIFF if subset==1

*C1
reg FTEDIFF STATE
*C2
reg FTEDIFF STATE bk kfc roys CO_OWNED
test bk kfc roys CO_OWNED

*C3
gen GAP = .

replace GAP = 0 if STATE==0
replace GAP = 0 if STATE==1 & WAGE_ST>=5.05
replace GAP = ((5.05/WAGE_ST)/WAGE_ST) if STATE==1 & WAGE_ST < 5.05

reg FTEDIFF GAP
*C4
reg FTEDIFF GAP bk kfc roys CO_OWNED
test bk kfc roys CO_OWNED
*C5
reg FTEDIFF GAP bk kfc roys CO_OWNED SOUTHJ CENTRALJ PA1 PA2
test bk kfc roys CO_OWNED SOUTHJ CENTRALJ PA1 PA2
