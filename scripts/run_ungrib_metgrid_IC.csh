#!/bin/csh -f
#
#-----------------------------------------------------------------------
# Script run_ungrib_metgrid_IC.csh
#
# Purpose: Run WPS to generate input files 
#
#-----------------------------------------------------------------------

source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_d01
source ${TOP_DIR}/realtime.cfg.${event}
source ${CENTRALDIR}/radar_files/radars.${event}.csh

###
set echo on
###

cd ${RUNDIR}

### First. remove residual files from last run:
#rm geogrid.log.00*
#rm geogrid.log
rm ${SEMA4}/geogrid_done
rm ${SEMA4}/ungrib*_done
rm ${SEMA4}/metgrid*_done
###

############################
# UNGRIB HRRRE ICs DATA 
# ############################

set n = 1
while ( $n <= $ENS_SIZE )

      mkdir ic$n

      cd ic$n

      if ( -e namelist.wps ) rm -f namelist.wps

      set startdate = " start_date = '${sdate}', '${sdate}',"
      set enddate = " end_date = '${sdate}', '${sdate}',"

      echo $startdate
      echo $enddate

      cp ${TEMPLATE_DIR}/namelist.wps.template.HRRRE .

      echo "&share" > namelist.wps
      echo " wrf_core = 'ARW'," >> namelist.wps
      echo " max_dom = 2," >> namelist.wps
      echo ${startdate} >> namelist.wps
      echo ${enddate} >> namelist.wps
      echo " interval_seconds = 3600" >> namelist.wps
      echo " io_form_geogrid = 2," >> namelist.wps
      echo "/" >> namelist.wps

      echo "&geogrid" >> namelist.wps
      echo " parent_id         = 1,  1," >> namelist.wps
      echo " parent_grid_ratio = 1,  3," >> namelist.wps
      echo " i_parent_start    = 1,  ${nest_i}," >> namelist.wps
      echo " j_parent_start    = 1,  ${nest_j}," >> namelist.wps
      echo " e_we              = ${grdpts_ew},  403," >> namelist.wps
      echo " e_sn              = ${grdpts_ns},  403," >> namelist.wps
      echo " geog_data_res     = 'bnu_soil_30s+modis_15s_lakes+maxsnowalb_modis+albedo_modis+modis_lai', 'modis_15s+modis_fpar+modis_lai+30s'," >> namelist.wps
      echo " dx = 3000," >> namelist.wps
      echo " dy = 3000," >> namelist.wps
      echo " map_proj = 'lambert'," >> namelist.wps
      echo " ref_lat   =  ${cen_lat}," >> namelist.wps
      echo " ref_lon   =  ${cen_lon}," >> namelist.wps
      echo " truelat1  =  30.00," >> namelist.wps
      echo " truelat2  =  60.00," >> namelist.wps
      echo " stand_lon =  ${cen_lon}," >> namelist.wps
      echo " geog_data_path = '/scratch/wof/realtime/geog'" >> namelist.wps
      echo " opt_geogrid_tbl_path = '${TEMPLATE_DIR}'" >> namelist.wps
      echo "/" >> namelist.wps

      cat namelist.wps.template.HRRRE >> namelist.wps

      ln -sf ${TEMPLATE_DIR}/Vtable.HRRRE.2018 ./Vtable

      @ anlys_hr = ${start_hr} - 1

      if ( $n < 10 ) then
#         ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/1400/postprd_mem000$n/wrfnat_hrrre_newse_mem000${n}_01.grib2 .
         ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/postprd_mem000$n/wrfnat_hrrre_newse_mem000${n}_01.grib2 .
      else
#         ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/1400/postprd_mem00$n/wrfnat_hrrre_newse_mem00${n}_01.grib2 .
         ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/${anlys_hr}00/postprd_mem00$n/wrfnat_hrrre_newse_mem00${n}_01.grib2 .
      endif

      echo "Linked HRRRE grib files for member " $n

      @ n++

      cd ..

end

###########################################################################
# UNGRIB
############################################################################

echo "#\!/bin/csh"                                                           >! ${RUNDIR}/ungrib_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH' "-J ungrib_mem"                                               >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH' "-o ${RUNDIR}/ic\%a/ungrib_mem\%a.log"                        >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH' "-e ${RUNDIR}/ic\%a/ungrib_mem\%a.err"                        >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH' "-A smallqueue"                                                >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH' "-p workq"                                                     >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH' "--ntasks-per-node=1"                                         >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH' "-n 1"                                                        >> ${RUNDIR}/ungrib_mem.csh
echo '#SBATCH -t 01:00:00'                                                    >> ${RUNDIR}/ungrib_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/ungrib_mem.csh
echo " "                                                                     >> ${RUNDIR}/ungrib_mem.csh
echo "set echo"                                                              >> ${RUNDIR}/ungrib_mem.csh
echo "source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_d01"                            >> ${RUNDIR}/ungrib_mem.csh
cat >> ${RUNDIR}/ungrib_mem.csh << EOF
source ${TOP_DIR}/realtime.cfg.${event}

setenv MPICH_VERSION_DISPLAY 1
setenv MPICH_ENV_DISPLAY 1
setenv MPICH_MPIIO_HINTS_DISPLAY 1
setenv MPICH_GNI_RDMA_THRESHOLD 2048
setenv MPICH_GNI_DYNAMIC_CONN disabled
setenv MPICH_CPUMASK_DISPLAY 1
setenv OMP_NUM_THREADS 1
setenv MPI_SOFTWARE openmpi

cd ${RUNDIR}/ic\${SLURM_ARRAY_TASK_ID}

sleep 2

srun ${RUNDIR}/WRF_RUN/ungrib.exe

sleep 1

touch ${SEMA4}/ungrib_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

sbatch --array=1-${ENS_SIZE} ${RUNDIR}/ungrib_mem.csh

while ( `ls -f ${SEMA4}/ungrib_mem*_done | wc -l` != $ENS_SIZE )
     echo "Waiting for ungribbing of GSD HRRRE Files"
     sleep 30
end

###########################################################################
# METGRID FOR ALL HRRRE MEMBERS
###########################################################################

set n = 1
while ( $n <= $ENS_SIZE )
      cd ic${n}
      ln -sf ${RUNDIR}/geo_em.d01.nc ./geo_em.d01.nc
      ln -sf ${RUNDIR}/geo_em.d02.nc ./geo_em.d02.nc
      @ n++
      cd ..
end

echo "#\!/bin/csh"                                                           >! ${RUNDIR}/metgrid_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-J metgrid_mem"                                              >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-o ${RUNDIR}/ic\%a/metgrid_mem\%a.log"                       >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-e ${RUNDIR}/ic\%a/metgrid_mem\%a.err"                       >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-A smallqueue"                                                >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-p workq"                                                     >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "--ntasks-per-node=24"                                         >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH' "-n 48"                                                        >> ${RUNDIR}/metgrid_mem.csh
echo '#SBATCH -t 00:30:00'                                                   >> ${RUNDIR}/metgrid_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_mem.csh
echo " "                                                                     >> ${RUNDIR}/metgrid_mem.csh
echo "set echo"                                                              >> ${RUNDIR}/metgrid_mem.csh
echo "source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_d01"                            >> ${RUNDIR}/metgrid_mem.csh
cat >> ${RUNDIR}/metgrid_mem.csh << EOF
source ${TOP_DIR}/realtime.cfg.${event} 

setenv MPICH_VERSION_DISPLAY 1
setenv MPICH_ENV_DISPLAY 1
setenv MPICH_MPIIO_HINTS_DISPLAY 1
setenv MPICH_GNI_RDMA_THRESHOLD 2048
setenv MPICH_GNI_DYNAMIC_CONN disabled
setenv OMP_NUM_THREADS 1
setenv MPI_SOFTWARE openmpi

cd ${RUNDIR}/ic\${SLURM_ARRAY_TASK_ID}

sleep 2    
 
srun ${RUNDIR}/WRF_RUN/metgrid.exe 

sleep 1 

rm HRRRE* GRIBFILE* 

touch ${SEMA4}/metgrid_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

sbatch --array=1-${ENS_SIZE} ${RUNDIR}/metgrid_mem.csh

while ( `ls -f  ${SEMA4}/metgrid_mem*_done | wc -l` != $ENS_SIZE )
      echo "Waiting for metgrid to finish for $ENS_SIZE members"
      sleep 30
end

echo "WPS is complete"

###########################################################################
exit 0
###########################################################################
