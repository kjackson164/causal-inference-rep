use lmdata, clear

scatter empc age if year == 86 & quebec == 1, ylabel(.5(.05).7) xline(29.5) // quebec men 1986
graph export scatter1.png
scatter empc age if year == 91 & quebec == 1, ylabel(.5(.05).7) xline(29.5) // quebec men 1991
graph export scatter2.png

scatter empc age if year == 86 & quebec == 0, ylabel(.5(.05).7) xline(29.5) // caanadian men 1986
graph export scatter3.png
scatter empc age if year == 91 & quebec == 0, ylabel(.5(.05).7) xline(29.5) // caanadian men 1991
graph export scatter4.png

gen low_bound = empc-1.96*sdempc/sqrt(nobs)
gen high_bound = empc+1.96*sdempc/sqrt(nobs)


/////// Figure 3 ////////

scatter empc age if year == 86 & quebec == 1 & age >= 25, ylabel(.48(.02).7) xlabel(24(1)40) xline(29.5) ///
|| line low_bound age if age>=25 & age<30 & year==86 & quebec==1, lpattern(dot) lcolor(black) ///
|| line high_bound age if age>=25 & age<30 & year==86 & quebec==1, lpattern(dot) lcolor(black) ///
|| line low_bound age if age>=25 & age<40 & year==86 & quebec==1, lpattern(dot) lcolor(black) ///
|| line high_bound age if age>=25 & age<40 & year==86 & quebec==1, lpattern(dot) lcolor(black) ///
|| lfit empc age if age>=25 & age<30 & year==86 & quebec==1, lcolor(black) ///
|| lfit empc age if age>=30 & age<40 & year==86 & quebec==1, lcolor(black) legend(off)


gen run1=(age-30.5)/10
///gen run1=(age-29.5)/10
///gen run1=(age-25)/10
///gen run1=(age-30-5)/10
///gen run1=(age-25)/10
gen run2=run1*run1
gen run3=run2*run1

gen cutoff=(age>=30)

gen int1=cutoff*run1
gen int2=cutoff*run2

gen va = nobs/sdempc^2

gen m = 0
replace m=1 if (quebec==1) & (year==86)

reg empc cutoff run1 [w=va] if (age>=25) & (m==1)
reg empc cutoff run1 run2 [w=va] if (age>=25) & (m==1)
reg empc cutoff run1 run2 run3 [w=va] if (age>=25) & (m==1)
reg empc cutoff run1 int1 [w=va] if (age>=25) & (m==1)
reg empc cutoff run1 run2 int1 int2 [w=va] if (age>=25) & (m==1)

rdplot empc age if year ==86 & quebec==1 & age>= 25, c(30.5) p(1)
