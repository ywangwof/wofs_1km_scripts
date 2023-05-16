#!/bin/csh -f
#
set echo

source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_rto_d01
source ${TOP_DIR}/retro.cfg.${event}

echo "Starting Script Run_ICBCs.csh"

set n = 1
while ( $n <= $HRRRE_BCS )
   set emember = ${n}
   @ emember2 = $emember + 18
#   @ emember3 = $emember + 18
#   @ emember4 = $emember + 27

   cd ${RUNDIR}/mem${emember}
   rm namelist.input.template
   ${LINK} ${RUNDIR}/input.nml ${RUNDIR}/mem${emember}/input.nml
   #
   echo ${PWD}

   ### 1st analysis time
   #setenv sdate1_12 2018-05-13_16:00:00
   #setenv edate1_12 2018-05-14_02:00:00
   #setenv sdate2 2018-05-14_03:00:00
   #setenv edate2 2018-05-14_12:00:00

   set start_year    = `echo $sdate |cut -c1-4`
   set start_month   = `echo $sdate |cut -c6-7`
   set start_day     = `echo $sdate |cut -c9-10`
   set start_hour    = `echo $sdate |cut -c12-13`
   set start_minute  = `echo $sdate |cut -c15-16`
   set start_second  = `echo $sdate |cut -c18-19`

   set end_year    = `echo $edate |cut -c1-4`
   set end_month   = `echo $edate |cut -c6-7`
   set end_day     = `echo $edate |cut -c9-10`
   set end_hour    = `echo $edate |cut -c12-13`
   set end_minute  = `echo $edate |cut -c15-16`
   set end_second  = `echo $edate |cut -c18-19`

   ### time interval between two analysis
   set interval_seconds = 3600
   #
   #
   cat > script.sed << EOF
/start_year/c \\
 start_year                          = $start_year, $start_year,
/start_month/c \\
 start_month                         = $start_month, $start_month,
/start_day/c \\
 start_day                           = $start_day, $start_day,
/start_hour/c \\
 start_hour                          = $start_hour, $start_hour,
/start_minute/c \\
 start_minute                        = $start_minute, $start_minute,
/start_second/c \\
 start_second                        = $start_second, $start_second,
/end_year/c \\
 end_year                            = $end_year, $end_year,
/end_month/c \\
 end_month                           = $end_month, $end_month,
/end_day/c \\
 end_day                             = $end_day, $end_day,
/end_hour/c \\
 end_hour                            = $end_hour, $end_hour,
/end_minute/c \\
 end_minute                          = $end_minute, $end_minute,
/end_second/c \\
 end_second                          = $end_second, $end_second,
/time_step_fract_num/c \\
 time_step_fract_num                 = 0,
/time_step_fract_den/c \\
 time_step_fract_den                 = 1,
/interval_seconds/c \\
 interval_seconds                    = $interval_seconds,
/max_dom/c \\
 max_dom                             = 1,
/e_we/c \\
 e_we                                = $grdpts_ew, 1,
/e_sn/c \\
 e_sn                                = $grdpts_ns, 1,
/i_parent_start/c \\
 i_parent_start                      = 0, 1,
/j_parent_start/c \\
 j_parent_start                      = 0, 1,
/numtiles/c \\
 numtiles                            = ${tiles},
/nproc_x/c \\
 nproc_x                             = -1,
/nproc_y/c \\
 nproc_y                             = -1,
/parent_grid_ratio/c \\
 parent_grid_ratio                   = 1, 5,
/parent_time_step_ratio/c\
 parent_time_step_ratio              = 1, 5,
/time_step/c \\
 time_step                           = 15,
/num_land_cat/c \\
 num_land_cat                        = 20,
EOF

###
    if ( ! -e namelist.input.template) cp ${TEMPLATE_DIR}/namelists.WOFS/namelist.input.member${emember} namelist.input.template


    sed -f script.sed namelist.input.template > namelist.input

    # run real.exe, rename wrfinput_d01 and wrfbdy_d01
    # ------------------------------------------------
   
    echo "#\!/bin/csh"                                                                >! ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo "#=================================================================="        >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo '#SBATCH' "-J mem${emember}/icbc_bc1"                                        >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo '#SBATCH' "-o ${RUNDIR}/mem${emember}/icbc_bc1.log"                          >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo '#SBATCH' "-e ${RUNDIR}/mem${emember}/icbc_bc1.err"                          >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo '#SBATCH' "-p batch"                                                         >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo '#SBATCH' "--mem-per-cpu=5G"                                             >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo '#SBATCH' "-n 12"                                                            >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo '#SBATCH -t 0:30:00'                                                         >> ${RUNDIR}/mem${emember}/icbc_bc1.csh
    echo "#=================================================================="        >> ${RUNDIR}/mem${emember}/icbc_bc1.csh

    cat >> ${RUNDIR}/mem${emember}/icbc_bc1.csh << EOF

    source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_rto_d01

    set echo

    cd \${SLURM_SUBMIT_DIR}

    cd ${RUNDIR}/mem${emember}/

    ln -sf ${RUNDIR}/WRF_RUN/real.exe real.exe
    ln -sf ${RUNDIR}/WRF_RUN/ETAMPNEW_DATA ETAMPNEW_DATA
    ln -sf ${RUNDIR}/WRF_RUN/GENPARM.TBL GENPARM.TBL
    ln -sf ${RUNDIR}/WRF_RUN/LANDUSE.TBL LANDUSE.TBL
    ln -sf ${RUNDIR}/WRF_RUN/RRTMG_LW_DATA RRTMG_LW_DATA
    ln -sf ${RUNDIR}/WRF_RUN/RRTMG_SW_DATA RRTMG_SW_DATA
    ln -sf ${RUNDIR}/WRF_RUN/RRTM_DATA RRTM_DATA
    ln -sf ${RUNDIR}/WRF_RUN/SOILPARM.TBL SOILPARM.TBL
    ln -sf ${RUNDIR}/WRF_RUN/VEGPARM.TBL VEGPARM.TBL
    ln -sf ${RUNDIR}/WRF_RUN/gribmap.txt gribmap.txt
    ln -sf ${RUNDIR}/WRF_RUN/tr49t67 tr49t67
    ln -sf ${RUNDIR}/WRF_RUN/tr49t85 tr49t85
    ln -sf ${RUNDIR}/WRF_RUN/tr67t85 tr67t85

    sleep 2

    srun --oversubscribe --mpi=pmi2 ${RUNDIR}/WRF_RUN/real.exe

    if ( ! -e wrfinput_d01) then
       echo !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!
       echo real.exe failed in generating wrfinput_d01 
    else if ( ! -e wrfbdy_d01  ) then
       echo !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!
       echo real.exe failed in generating wrfbdy_d01
    else
       echo Done with Input and Boundary files for BC1

       rm -rf wrfinput_d01
       sleep 2
    endif

    ${MOVE} ${RUNDIR}/mem${emember}/wrfbdy_d01 ${RUNDIR}/mem${emember}/wrfbdy_d01.${emember}
    sleep 1
    ${COPY} ${RUNDIR}/mem${emember}/wrfbdy_d01.${emember} ${RUNDIR}/mem${emember2}/wrfbdy_d01.${emember2}
    sleep 1

    touch ${SEMA4}/bc1_mem${emember}_done

    #${REMOVE} rsl*

EOF

   chmod +x ${RUNDIR}/mem${emember}/icbc_bc1.csh
   sbatch ${RUNDIR}/mem${emember}/icbc_bc1.csh

   sleep 1
   @ n++
end

# COMBINE WRFBDY FILES
#while ( ! -e ${SEMA4}/bc1_mem${emember}_done )
#  echo "WAIT FOR ALL WRFBDY FILES TO FINISH"
#  sleep 5
#end

#${MOVE} ${RUNDIR}/mem${emember}/wrfbdy_d01 ${RUNDIR}/mem${emember}/wrfbdy_d01.${emember}
#sleep 1
#
#
#${COPY} ${RUNDIR}/mem${emember}/wrfbdy_d01.${emember} ${RUNDIR}/mem${emember2}/wrfbdy_d01.${emember2}
#sleep 1
#${COPY} ${RUNDIR}/mem${emember}/wrfbdy_d01.${emember} ${RUNDIR}/mem${emember3}/wrfbdy_d01.${emember3}
#sleep 1
#${COPY} ${RUNDIR}/mem${emember}/wrfbdy_d01.${emember} ${RUNDIR}/mem${emember4}/wrfbdy_d01.${emember4}
exit (0)
###################################################################################################################
