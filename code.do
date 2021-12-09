cd "C:\Users\sda81\OneDrive - Brigham Young University\388 Stata\Data Assignment 3"
clear
import delimited using us-counties-2020.csv

collapse (sum) deaths cases, by(fips state county)
edit
summ deaths
total deaths
save us-counties-2020, replace

clear
import delimited using DECENNIALPL2020.P1_data_with_overlays_2021-12-02T110116.csv // Using data from 2010 census

merge 1:m fips using us-counties-2020
sort _merge
drop if _merge!=3
drop id geographicareaname _merge

save counties-population-2020, replace


import excel "C:\Users\sda81\OneDrive - Brigham Young University\388 Stata\Data Assignment 3\ZIP_COUNTY_032020.xlsx", sheet("ZIP_COUNTY_032020") firstrow clear
destring ThreeDigitZIPCode, replace
drop ZIP RES_RATIO BUS_RATIO OTH_RATIO TOT_RATIO
save ZIP_COUNTY_032020, replace

import excel "C:\Users\sda81\OneDrive - Brigham Young University\388 Stata\Data Assignment 3\HPI_AT_3zip.xlsx", sheet("HPI_AT_3zip") firstrow clear
keep if Year==2020
collapse (mean) IndexNSA, by(ThreeDigitZIPCode Year)
gen y20 = Year==2020
gen IndNSA20 = IndexNSA if y20
drop Year IndexNSA
save HPI-2020, replace

import excel "C:\Users\sda81\OneDrive - Brigham Young University\388 Stata\Data Assignment 3\HPI_AT_3zip.xlsx", sheet("HPI_AT_3zip") firstrow clear
keep if Year==2021
collapse (mean) IndexNSA, by(ThreeDigitZIPCode Year)
gen y21 = Year==2021
gen IndNSA21 = IndexNSA if y21
drop Year IndexNSA

merge 1:m ThreeDigitZIPCode using HPI-2020 // Fix Year!! // Possibly rename IndexNSA to ind20 and in the other file ind21 and then merge.
drop _merge

merge 1:m ThreeDigitZIPCode using ZIP_COUNTY_032020
sort _merge
drop if _merge!=3
drop _merge
destring fips, replace

save zip-house, replace

merge m:m fips using counties-population-2020
drop if _merge!=3
drop _merge

collapse (mean) IndNSA21 IndNSA20, by(fips county state deaths cases population y21 y20)
gen IndNSAChange = IndNSA21 - IndNSA20
gen deathrate = deaths/population
gen caserate = cases/population
gen ldeathrate = log(deathrate)
gen lcaserate = log(caserate)
gen lIndNSAChange = log(IndNSAChange)
regress IndNSAChange ldeathrate
regress IndNSAChange deathrate caserate


twoway scatter IndNSAChange deathrate

ssc install asdoc
asdoc summ population deaths cases deathrate caserate IndNSA21 IndNSA20 IndNSAChange, save(test3.doc)

// When collapsing on "collapse (mean) IndNSA21 IndNSA20, by(fips county state deaths cases population y21 y20)", it weights each zip equally even though there might be more of one zip code than others per county.
//Another limitation would be trying to find population data for 2021, to see the change in population for each county.
// Is the deathrate a good indicator for the price change or is it the quarantine?





