#!/bin/csh

### Setup directories and link associated stuff to get WoFS started.
### Run this script BEFORE anything else kicks off.

set scrptdir=$0:h
set scrptdir=`realpath ${scrptdir}`
set parentdir=${scrptdir:h}

if ($#argv == 1 ) then
    set realconfig = $argv[1]
else
    set realconfig = ${parentdir}/WOFenv_rto_d01
endif

source ${realconfig}

set eventstr = `date -d "$event" +%Y-%m-%d`
set eventyr = `date -d "$event" +%Y`
set eventmn = `date -d "$event" +%m`
set eventdy = `date -d "$event" +%d`
set eventnxt = `date -d "$event 1 days" +%Y%m%d`
set eventnxstr = `date -d "$eventnxt" +%Y-%m-%d`
set eventnxyr = `date -d "$eventnxt" +%Y`
set eventnxmn = `date -d "$eventnxt" +%m`
set eventnxdy = `date -d "$eventnxt" +%d`


#set echo
source ${CENTRALDIR}/radar_files/radars.${event}.csh

echo "setenv sdate ${eventstr}_15:00:00" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv edate ${eventnxstr}_07:00:00" >> ${TOP_DIR}/retro.cfg.${event}

### Set running days variables
echo "setenv runyr $eventyr" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv runmon $eventmn" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv runday $eventdy" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv nxtyr $eventnxyr" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv nxtmon $eventnxmn" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv nxtday $eventnxdy" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv runDay $event" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv nxtDay $eventnxt" >> ${TOP_DIR}/retro.cfg.${event}

### NCYCLE_* is number of particular analysis cycles
echo "setenv NCYCLE_1H 36" >> ${TOP_DIR}/retro.cfg.${event}

### Set start cycle and cycling period
echo "setenv cycle_start ${start_hr}" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv cycleinterval 15" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv assim_per_conv 15" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv waitinterval 8" >> ${TOP_DIR}/retro.cfg.${event}

### Set up primary directory paths
echo "setenv TOP_DIR ${TOP_DIR}" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SCRIPTDIR ${SCRIPTDIR}" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv RUNDIR ${RUNDIR}" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv FCST_DIR ${TOP_DIR}/FCST/${event}" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv TEMPLATE_DIR /scratch/wofs_1km/wofs_1km_templates" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv WRFDIR /home/wofuser/WOFS/WRFV3.9_WOFS" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv WPSDIR /home/wofuser/WOFS/WPSV3.7.1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv GSIDIR /home/wofuser/WOFS/WOFS-GSI" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ENKFDIR ${RUNDIR}/enkfdir" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv RESULTSDIR ${RUNDIR}/results" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ADDNOISEDIR /scratch/wofs_1km/wofs_dart_utils-master/" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv DARTDIR /home/wofuser/WOFS/DART-mhn" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SEMA4 ${RUNDIR}/flags" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv HRRRE_DIR /scratch/wofuser/MODEL_DATA/HRRRE" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv REF_DIR /scratch/wofs_1km/OBSGEN/REF/D01" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv VEL_DIR /scratch/wofs_1km/OBSGEN/VEL/D01" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SGP_DIR /scratch/junjun.hu/realtime/OBSGEN" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SAT_DIR /work/rt_obs/Satellite" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv OBSDIR /work/rt_obs/" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv INPUTDIR ${TOP_DIR}/WRFINPUTS" >> ${TOP_DIR}/retro.cfg.${event}

### Number of ensembles
echo "setenv ENS_SIZE 36" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv NANALS 36" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv HRRRE_BCS 18" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv FCST_SIZE 18" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv HFCST_SIZE 9" >> ${TOP_DIR}/retro.cfg.${event}

### Set number of domains
echo "setenv domains 1" >> ${TOP_DIR}/retro.cfg.${event}

### Set grid dimensions
echo "setenv grdpts_ew 301" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv grdpts_ns 301" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv grdpts_ew2 403" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv grdpts_ns2 403" >> ${TOP_DIR}/retro.cfg.${event}

### Number of soil levels in model data
echo "setenv num_soil_levels 4" >> ${TOP_DIR}/retro.cfg.${event}

### WRF Namelist runtime information
echo "setenv procx -1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv procy -1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv procxf -1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv procyf -1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv tiles 1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv tilesf 1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ts 12" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv fts 12" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv NCYCLE_IC 1" >> ${TOP_DIR}/retro.cfg.${event}

### Number of cores for MPI runs
echo "setenv GSI_CORES 4" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv EKF_CORES 480" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv EKF_NODES 20" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv INF_NODES 4" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv WRF_CORES 32" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv WRF_FCORES 48" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv INF_CORES 120" >> ${TOP_DIR}/retro.cfg.${event}

### Wait time for radar observation files to be generated
echo "setenv waitinterval 11" >> ${TOP_DIR}/retro.cfg.${event}

### Version of GOES FILES to be assimilated
echo "setenv GOESV 16" >> ${TOP_DIR}/retro.cfg.${event}

### ADD NOISE VARIABLES
echo "setenv lh 9000.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv lv 3000.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv u_sd 0.50" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv v_sd 0.50" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv w_sd 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv t_sd 0.50" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv td_sd 0.50" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv qv_sd 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv iseed 1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv iseed2 1" >> ${TOP_DIR}/retro.cfg.${event}

### GSI STUFF
echo "setenv NZ 51" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv NLEVS 50" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv DTinner 12" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv geog_data_resouter 10m" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv radt1 5" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv OUTLIER 3.25" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv COVINFLATENH 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv COVINFLATESH 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv COVINFLATETR 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LOCVERTOPT 1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LOCHOROPT 1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LNSIGCOVINFCUTOFF 6" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv USE_RH .false." >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ANALPERTWTNH 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ANALPERTWTNHMULTI 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ANALPERTWTNH3KM 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ANALPERTWTSH 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ANALPERTWTTR 0.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv COVINFLATEMAX 1.e2" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv COVINFLATEMIN 1.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv CORRLENGTHNH 460" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv CORRLENGTHSH 460" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv CORRLENGTHTR 460" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv OBTIMELNH 1.e30" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv OBTIMELSH 1.e30" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv OBTIMELTR 1.e30" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv IASSIM_ORDER 0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LNSIGCUTOFFNH 0.45" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LNSIGCUTOFFSH 0.45" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LNSIGCUTOFFTR 0.45" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LNSIGCUTOFFPSNH 0.45" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LNSIGCUTOFFPSSH 0.45" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv LNSIGCUTOFFPSTR 0.45" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SIMPLE_PARTITION .true." >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv NLONS 300" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv NLATS 300" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SMOOTHPARM -1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv NVARS 22" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PRIOR_INF 1" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PRIOR_INF_INITIAL 1.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PRIOR_INF_SD_INITIAL 0.6" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PRIOR_INF_DAMPING 0.9" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PRIOR_INF_LOWER_BOUND 1.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PRIOR_INF_UPPER_BOUND 100.0" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PRIOR_INF_SD_LOWER_BOUND 0.6" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv BYTE_ORDER Big_Endian" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv FIX_ROOT ${CENTRALDIR}/FIX_FILES/" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SATANGL ${CENTRALDIR}/FIX_FILES/global_satangbias.txt" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SATINFO ${CENTRALDIR}/FIX_FILES/satinfo.txt" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv CONVINFO ${CENTRALDIR}/FIX_FILES/doubled_error_tolerance.txt" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv OZINFO ${CENTRALDIR}/FIX_FILES/global_ozinfo.txt" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv BERROR ${CENTRALDIR}/FIX_FILES/berror_stats" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv OBERROR ${CENTRALDIR}/FIX_FILES/nam_errtable.r3dv" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv ANAVINFO ${CENTRALDIR}/FIX_FILES/anavinfo" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv PCPINFO ${CENTRALDIR}/FIX_FILES/global_pcpinfo.txt" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SATBIASING ${CENTRALDIR}/FIX_FILES/satbias_in.gsi.start.ABI" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SATBIASINE ${CENTRALDIR}/FIX_FILES/satbias_in.enkf.start.ABI" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv SATBIASPC ${CENTRALDIR}/FIX_FILES/satbias_pc.enkf.start.ABI" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv CRTM_DIR /home/thomas.jones/GSI_CODE/comGSIv3.6_EnKFv1.2_LPF_GX/CRTM_2.3/Big_Endian" >> ${TOP_DIR}/retro.cfg.${event}

### Convenient utils; probably should be ALIAS's...
#  System specific commands
echo "setenv   REMOVE 'rm -f'" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv   REMOVEDIR 'rm -rf'" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv   COPY '/bin/cp -p'" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv   MOVE '/bin/mv'" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv   LINK 'ln -fs'" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv   WGET /usr/bin/wget" >> ${TOP_DIR}/retro.cfg.${event}

### Logfiles
echo "setenv logWPSBCs "${RUNDIR}"/WPSBCs.log" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv logWPSICs "${RUNDIR}"/WPSICs.log" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv logWPSIND "${RUNDIR}"/WPSIND.log" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv logREALBCs "${RUNDIR}"/BCs.log" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv logREALICs "${RUNDIR}"/ICs.log" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv logIcbcIND "${RUNDIR}"/ICBCIND.log" >> ${TOP_DIR}/retro.cfg.${event}
echo "setenv logConv "${RUNDIR}"/ConvMAIN.log" >> ${TOP_DIR}/retro.cfg.${event}

source ${TOP_DIR}/retro.cfg.${event}

mkdir $RUNDIR
cd $RUNDIR
mkdir -p ${RUNDIR}/flags

if ( $start_hr == 12 ) then
   set cycles = ( 12 13 14 15 16 17 18 19 20 21 22 23 )
endif

if ( $start_hr == 15 ) then
   set cycles = ( 15 16 17 18 19 20 21 22 23 )
endif

if ( $start_hr == 17 ) then
   set cycles = ( 17 18 19 20 21 22 23 )
endif

if ( $start_hr == 18 ) then
   set cycles = ( 18 19 20 21 22 23 )
endif

if ( $start_hr == 21 ) then
   set cycles = ( 21 22 23 )
endif

foreach hr ( $cycles )

   foreach mte ( 00 15 30 45 )

     mkdir -p ${RUNDIR}/${runDay}${hr}${mte}

   end

end

foreach hr2 ( 00 01 02 03 04 05 )
#foreach hr2 ( 00 01 02 )

   foreach mte ( 00 15 30 45 )

      mkdir -p ${RUNDIR}/${nxtDay}${hr2}${mte}

   end

end

mkdir -p ${RUNDIR}/${nxtDay}0600
#mkdir -p ${RUNDIR}/${nxtDay}0300

mkdir -p ${RUNDIR}/WRF_RUN
mkdir -p ${RUNDIR}/GSI_RUN
mkdir -p ${FCST_DIR}
#mkdir -p ${FCST_DIR}/HIRES

cd ${RUNDIR}

###########################################################################

cp -R ${DARTDIR}/models/wrf/work/advance_time .
cp -R ${DARTDIR}/models/wrf/work/convertdate .
cp -R ${DARTDIR}/models/wrf/work/update_wrf_bc .

cp -R ${TEMPLATE_DIR}/input.nml.conv1 ./input.nml
cp -R ${TEMPLATE_DIR}/namelists.WOFS/namelist.input.member1 namelist.input

###########################################################################

touch ${SEMA4}/ConvRun
touch ${logWPSBCs}
touch ${logWPSICs}
touch ${logREALBCs}
touch ${logREALICs}
touch ${logConv}

cd ${RUNDIR}/WRF_RUN

cp -R ${WPSDIR}/geogrid/src/geogrid.exe .
cp -R ${WPSDIR}/ungrib/src/ungrib.exe .
cp -R ${WPSDIR}/metgrid/src/metgrid.exe .
cp -R ${WPSDIR}/link_grib.csh .
cp -R ${WRFDIR}/run/CCN_ACTIVATE.BIN .
cp -R ${WRFDIR}/run/ETAMPNEW_DATA ETAMPNEW_DATA
cp -R ${WRFDIR}/run/GENPARM.TBL GENPARM.TBL
cp -R ${WRFDIR}/run/LANDUSE.TBL LANDUSE.TBL
cp -R ${WRFDIR}/run/RRTM_DATA RRTM_DATA
cp -R ${WRFDIR}/run/RRTMG_SW_DATA RRTMG_SW_DATA
cp -R ${WRFDIR}/run/RRTMG_LW_DATA RRTMG_LW_DATA
cp -R ${WRFDIR}/run/SOILPARM.TBL SOILPARM.TBL
cp -R ${WRFDIR}/run/VEGPARM.TBL VEGPARM.TBL
cp -R ${WRFDIR}/run/gribmap.txt gribmap.txt
cp -R ${WRFDIR}/run/*.formatted .
cp -R ${WRFDIR}/run/bulk* .
cp -R ${WRFDIR}/run/CAM* .
cp -R ${WRFDIR}/run/CLM* .
cp -R ${WRFDIR}/run/c* .
cp -R ${WRFDIR}/run/grib2map.tbl .
cp -R ${WRFDIR}/run/ker* .
cp -R ${WRFDIR}/run/masses.asc .
cp -R ${WRFDIR}/run/MPTABLE.TBL .
cp -R ${WRFDIR}/run/RRTMG_LW_DATA_DBL .
cp -R ${WRFDIR}/run/RRTMG_SW_DATA_DBL .
cp -R ${WRFDIR}/run/termvels.asc .
cp -R ${WRFDIR}/run/tr49t67 tr49t67
cp -R ${WRFDIR}/run/tr49t85 tr49t85
cp -R ${WRFDIR}/run/tr67t85 tr67t85
cp -R ${WRFDIR}/main/real.exe .
cp -R ${WRFDIR}/main/ndown.exe .
cp -R ${WRFDIR}/main/wrf.exe .
#cp -R ${DARTDIR}/models/wrf/work/update_wrf_bc .

cp -R ${CENTRALDIR}/wofs_dart_utils-master/add_pert_where_high_refl.exe .
cp -R ${CENTRALDIR}/wofs_dart_utils-master/grid_refl_obs_gsi.exe .
cp -R ${CENTRALDIR}/wofs_dart_utils-master/WRF_BC/update_wrf_bc.exe .
cp -R ${CENTRALDIR}/wofs_dart_utils-master/advance_time .
cp -R ${CENTRALDIR}/wofs_dart_utils-master/convertdate .
cp -R ${CENTRALDIR}/wofs_dart_utils-master/input.nml  .

cd ${RUNDIR}/GSI_RUN

cp -R ${GSIDIR}/src/gsi.exe .
cp -R ${GSIDIR}/src/enkf/init_inf .
cp -R ${GSIDIR}/src/enkf/prior_inf .
cp -R ${GSIDIR}/src/enkf/wrf_enkf .

chmod -R 775 $RUNDIR

echo "Done with initial setup"

exit (0)

