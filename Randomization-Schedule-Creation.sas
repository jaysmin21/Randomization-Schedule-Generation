/******Problem 1******/
/*creating a randomization schedule: n=480, block size=6*/
proc plan seed=1133637;
	factors blocks=80 ordered trt=6 random/noprint;
output out=randlist trt cvals=('A' 'A' 'B' 'B' 'B' 'B');
run;quit;
/*including ID variable*/
data randlist_final;
set randlist;
patient+1;
run;

proc print data=randlist_final (obs=20)
label noobs;
var patient trt blocks;
label patient="Patient ID" trt="Treatment";
title1 'Uncomplicated Plasmodium Falciparum Malaria';
title2 'Protocol Randomization Schedule';
run;

/*creating a randomization schedule: n=480, random block size= 3, 6*/

/*generating random size of blocks*/
data blocks;
do block=1 to 160; /*480 / 3 = 160 - in case we randomly get all block sizes of 3*/
half_size=rantbl(1133637, 0.5, 0.5);
size=half_size*3;
output;
end;
run;

data blocks;
set blocks;
do j=1 to half_size;
do treatment="A","B", "B"; /*to still make it 1:2*/
random = ranuni(1133637);
output;
end;
end;
run;

proc sort data=blocks;
by block random;
run;
/*Adding Labels*/
data blocks_final;
set blocks;
id=_n_;
label treatment='Treatment Group'
		block='Block number'
		id='Study ID';
	keep id treatment;
run;
proc print data=blocks_final (obs=20) noobs label;
var id treatment;
label id='Patient ID' Treatment='Treatment';
run;

/*creating a stratified randomization schedule for 3 regions, 2 age groups*/
proc plan seed=1133637;
	factors country=3 ordered age=2 ordered blocks=50 ordered trt=6 random/noprint; /*add ordered after each factor*/
output out=randlist_strat trt cvals=('A' 'A' 'B' 'B' 'B' 'B');
run;quit;

data randlist_strat;
set randlist_strat;
patient+1;
run;
title1 'Uncomplicated Plasmodium Falciparum Malaria';
title2 'Protocol Randomization Schedule - Stratified';
proc print data=randlist_strat(obs=10) noobs label;
where age=1 and country=1;
var patient trt;
label patient='Patient ID' trt='Treatment';
run;

proc print data=randlist_strat(obs=10) noobs label;
where age=1 and country=2;
var patient trt;
label patient='Patient ID' trt='Treatment';
run;

proc print data=randlist_strat(obs=10) noobs label;
where age=1 and country=3;
var patient trt;
label patient='Patient ID' trt='Treatment';
run;

proc print data=randlist_strat(obs=10) noobs label;
where age=2 and country=1;
var patient trt;
label patient='Patient ID' trt='Treatment';
run;

proc print data=randlist_strat(obs=10) noobs label;
where age=2 and country=2;
var patient trt;
label patient='Patient ID' trt='Treatment';
run;

proc print data=randlist_strat(obs=10) noobs label;
where age=2 and country=3;
var patient trt;
label patient='Patient ID' trt='Treatment';
run;


/******Problem 2******/
/*randomization schedule for n=168, 3 treatment groups, 4 sites, 1:1:1 ratio*/
proc plan seed=1133637;
	factors site=4 ordered blocks=10 /*168/4sites =42, 42/6 = 7 blocks*/
	trt=6 /*chosen block size of 6*/random/noprint;
	output out = randschd trt cvals=('6 month' '6 month' '4 month' '4 month' '3 month' '3 month');
	run;
quit;

data randschd;
retain site patid trt;
set randschd;
	by site;
		if first.site then patient=0;
		patient+1;
	if site=1 then patid=patient+100;
	if site=2 then patid=patient+200;
	if site=3 then patid=patient+300;
	if site=4 then patid=patient+400;
run;
data randschd_final;
set randschd;
keep patid site trt;
run;
proc print data=randschd_final label noobs;
	var patid site trt;
	label patid="Patient ID" trt="Treatment" site='Site';
	title1 'Protocol XXXX Randomization Schedule';
	run;
/* Export final randomization schedule to Excel */
	data randschd_final_out;
set randschd_final;
keep patid site trt;
	label patid="Patient ID" trt="Treatment" site='Site'; /*need the label statement for it to show up on exported files in the DATA STEP*/
run;
proc export data=randschd_final_out
    outfile="C:\MPH\851\Datasets\randschdout.xlsx"
    dbms=xlsx 
label
replace;
    sheet="Randomization_Schedule";

run;

