#!/bin/csh 

########################################################################
#
#	RUN WoFS SYSTEM
#       Assimilates: MRMS reflectivity and radial velocity,
#               GOES CWP, OK Mesonset data, prebufr conventional observations
#
########################################################################

source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_rto_d01
set ENVFILE = ${TOP_DIR}/retro.cfg.${event}
source ${ENVFILE}

set echo
set startdate=${event}${cycle_start}
set datea = 202205061515
set datef = 202205061515

cd ${RUNDIR}


## main loop over data assimilation cycles

while (1 == 1)
  
  set daten  =  `echo  ${datea} ${cycleinterval}m | ${RUNDIR}/advance_time`
  echo $daten

  set thisstart = ${datea}
  set thisend = ${daten}
 
  set startyear  = `echo ${thisstart} | cut -c1-4`
  set startmonth = `echo ${thisstart} | cut -c5-6`
  set startday   = `echo ${thisstart} | cut -c7-8`
  set starthour  = `echo ${thisstart} | cut -c9-10`
  set startmin   = `echo ${thisstart} | cut -c11-12` 
 
  set endyear  = `echo ${thisend} | cut -c1-4`
  set endmonth = `echo ${thisend} | cut -c5-6`
  set endday   = `echo ${thisend} | cut -c7-8`
  set endhour  = `echo ${thisend} | cut -c9-10`
  set endmin   = `echo ${thisend} | cut -c11-12`

  ${REMOVE} -rf ${ENKFDIR}/enkfrun*
  ${REMOVE} -rf ${ENKFDIR}/*_done

#    set imem = 1
#    while ( ${imem} <= 36 )
#     ln -sf ${RUNDIR}/mem${imem}/wrfbdy_d01.${imem} ${ENKFDIR}/wrfbdy_d01.${imem}
#     @ imem++
#    end

#    cd ${ENKFDIR}

###### APPLY ADDITIVE NOISE AND ADVANCE ENSEMBLE MEMBERS
# SET ADDITIVE NOISE FLAG TO FALSE FOR FIRST CYELE
     set noise_flag = 1

     if ( ${starthour}${startmin} == ${cycle_start}00 ) then
        set noise_flag = 0
     endif

set imem = 1
while ( ${imem} <= 36 )
     echo "#\!/bin/csh"     	         	                                 >! ${RUNDIR}/adv_wrf_mem${imem}.job
     echo "#=================================================================="  >> ${RUNDIR}/adv_wrf_mem${imem}.job
     echo '#SBATCH' "-J adv_wrf_mem${imem}"                                             >> ${RUNDIR}/adv_wrf_mem${imem}.job
     echo '#SBATCH' "-o ${RUNDIR}/adv_wrf_mem${imem}.log"                            >> ${RUNDIR}/adv_wrf_mem${imem}.job
     echo '#SBATCH' "-e ${RUNDIR}/adv_wrf_mem${imem}.err"                            >> ${RUNDIR}/adv_wrf_mem${imem}.job
     echo '#SBATCH' "-A largequeue"                                                     >> ${RUNDIR}/adv_wrf_mem${imem}.job
     echo '#SBATCH' "-p workq"                                          >> ${RUNDIR}/adv_wrf_mem${imem}.job
     echo '#SBATCH' "--ntasks-per-node=24"                                       >> ${RUNDIR}/adv_wrf_mem${imem}.job 
     echo '#SBATCH' "-n ${WRF_CORES}"                                            >> ${RUNDIR}/adv_wrf_mem${imem}.job
     echo '#SBATCH' "-t 0:30:00"                                                 >> ${RUNDIR}/adv_wrf_mem${imem}.job 
     echo "#=================================================================="  >> ${RUNDIR}/adv_wrf_mem${imem}.job

     cat >> ${RUNDIR}/adv_wrf_mem${imem}.job << EOF
     
     source ${ENVFILE}
     set echo

     setenv MPICH_VERSION_DISPLAY 1
     setenv MPICH_ENV_DISPLAY 1
     setenv MPICH_MPIIO_HINTS_DISPLAY 1

     setenv MPICH_GNI_RDMA_THRESHOLD 2048
     setenv MPICH_GNI_DYNAMIC_CONN disabled
     setenv MPICH_CPUMASK_DISPLAY 1

     setenv OMP_NUM_THREADS 1

     if ( -d "${RUNDIR}/enkfrun${imem}" ) then
      ${REMOVEDIR} ${RUNDIR}/enkfrun${imem}
     endif
     
     mkdir ${RUNDIR}/enkfrun${imem}
     cd ${RUNDIR}/enkfrun${imem} 

     ${SCRIPTDIR}/runwrf_conv.csh ${imem} ${thisstart} ${thisend} ${ENVFILE}
     cp -f ${TEMPLATE_DIR}/input.nml.conv1.1km ./input.nml
     cp -f ${ADDNOISEDIR}/add_pert_where_high_refl ./add_pert_where_high_refl
     cp -f ${ENKFDIR}/refl_obs.txt ./refl_obs.txt

     if ( ${noise_flag} == 1 ) then 
        ./add_pert_where_high_refl refl_obs.txt wrfinput_d01 $lh $lv $u_sd $v_sd $w_sd $t_sd $td_sd $qv_sd ${iseed} ${iseed2} ${imem}  > ./addnoise.output.${imem}
     endif

     sleep 2
     ./update_wrf_bc > ./update_wrf_bc.output.${imem}
     sleep 2
     
     srun ${RUNDIR}/WRF_RUN/wrf.exe
     sleep 2

     if ( -e ${RUNDIR}/enkfrun${imem}/wrfout_d01_${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:00 ) then
      ${MOVE} ${RUNDIR}/enkfrun${imem}/wrfout_d01_${startyear}-${startmonth}-${startday}_${starthour}:${startmin}:00 ${RUNDIR}/${thisstart}/wrfout_d01_${startyear}-${startmonth}-${startday}_${starthour}:${startmin}:00_${imem}
      ${COPY} ${RUNDIR}/enkfrun${imem}/wrfout_d01_${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:00 ${RUNDIR}/${thisstart}/wrffcst_d01_${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:00_${imem}
      ${MOVE} ${RUNDIR}/enkfrun${imem}/wrfout_d01_${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:00 ${ENKFDIR}/wrfinput_d01.${imem}
      ${MOVE} ${RUNDIR}/enkfrun${imem}/wrfout_d02_${startyear}-${startmonth}-${startday}_${starthour}:${startmin}:00 ${CENTRALDIR}/D02/${event}/${thisstart}/wrfout_d02_${startyear}-${startmonth}-${startday}_${starthour}:${startmin}:00_${imem}
      ${COPY} ${RUNDIR}/enkfrun${imem}/wrfout_d02_${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:00 ${CENTRALDIR}/D02/${event}/${thisstart}/wrffcst_d02_${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:00_${imem}
      ${MOVE} ${RUNDIR}/enkfrun${imem}/wrfout_d02_${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:00 ${CENTRALDIR}/D02/${event}/enkfdir/wrfinput_d02.${imem}

      ${COPY} ${RUNDIR}/enkfrun${imem}/rsl.error.0000  ${RUNDIR}/${thisstart}/rsl.error.0000_${imem}
      sleep 1
      touch ${RUNDIR}/adv_wrf_done${imem}
     endif 

     exit 0

EOF

     #SUBMIT ALL MEMBERS AT ONCE
     sbatch ${RUNDIR}/adv_wrf_mem${imem}.job
     @ imem++

end
exit(0)
## CHECK TO SEE IF ALL MEMBERS HAVE FINISHED AND MOVE FILES AROUND
     set imem = 1
     while ( ${imem} <= 18 )
        while ( ! -e ${RUNDIR}/adv_wrf_done${imem} )
         echo "WAITING FOR MEMBER "${imem}" TO FINISH"
         sleep 3
        end

       ${REMOVE} enkfrun${imem}/rsl*

       @ imem++
     end

    # CLEAN UP THINGS
    ${MOVE} ${ENKFDIR}/refl_obs.txt ${ENKFDIR}/refl_obs_${thisstart}.txt
    ${REMOVE} ${RUNDIR}/*done*
    ${REMOVE} ${RUNDIR}/*job
#    ${MOVE} ${RUNDIR}/${datea}/*err
    ${REMOVE} ${ENKFDIR}/gridrefl*
    ${REMOVE} ${ENKFDIR}/nceamean01_sm.*

   echo "*** DONE ADVANCE MEMBERS"

   ### CALCULATE ENSEMBLE MEAN REFL FORECAST (use as prior mean for next cycle)
   cd ${ENKFDIR}
   ${REMOVE} ${ENKFDIR}/wrfinput_d01*ensmean
   ${COPY} ${SCRIPTDIR}/run_nceamean_conv_d01.job .
   sbatch run_nceamean_conv_d01.job

   while ( ! -e ${ENKFDIR}/ensmean_done01 )
     echo "WAITING FOR ENSEMBLE MEAN TO FINISH"
     sleep 3
   end
   ${REMOVE} ${ENKFDIR}/ensmean_done01
   ${REMOVE} ${ENKFDIR}/nceamean01.*

   ### MOVE FILES TO RESULTS DIRECTORY
   ${MOVE} ${ENKFDIR}/diag* ${RUNDIR}/${thisstart}
   ${REMOVE} ${ENKFDIR}/copy*output*
   ### KEEP VROBS FOR COMPARISON
   #${MOVE} ${ENKFDIR}/vrobs.nc ${ENKFDIR}/vrobs_mask_${thisstart}.nc
   ${REMOVE} ${ENKFDIR}/*nc
   ${REMOVE} ${ENKFDIR}/*mdf
   ${REMOVE} ${ENKFDIR}/*bufr

   grep cfl ${RUNDIR}/enkfrun*/rsl* > ${RUNDIR}/cfl.log.${thisstart}

   # Advance to the next time if this is not the final time
    if ( $datea == $datef ) then
	  echo "Script exiting normally"
        # CLEAN UP AND MOVE FINAL THINGS
 	  exit
     else
	  echo "Starting next time"
          set datea  =  `echo  ${datea} ${cycleinterval}m | ${RUNDIR}/advance_time`
     endif

     #if ( $datea > 202004191700 ) then
	     #	sleep 300
	     #endif

end	# END CYCLE WHILE LOOP

##########################################################################################
