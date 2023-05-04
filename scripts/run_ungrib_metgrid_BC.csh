#!/bin/csh -f
#
#-----------------------------------------------------------------------
# Script Nested_WPS.csh
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
rm -fr mem*
rm ungrib_bc_mem.csh metgrid_bc_mem.csh
rm ${SEMA4}/geogrid_done
rm ${SEMA4}/ungrib*_done
rm ${SEMA4}/metgrid*_done

###

############################
# UNGRIB HRRRE ICs DATA 
# ############################

set n = 1
while ( $n <= $ENS_SIZE )

      mkdir mem$n

      if ( $n <= $HRRRE_BCS ) then

      cd mem$n

      if ( -e namelist.wps ) rm -f namelist.wps

      set startdate = " start_date = '${sdate}', '${sdate}',"
      set enddate = " end_date = '${edate}', '${edate}',"

      echo $startdate
      echo $enddate

      cp ${TEMPLATE_DIR}/namelist.wps.template.HRRRE .

      echo "&share" > namelist.wps
      echo " wrf_core = 'ARW'," >> namelist.wps
      echo " max_dom = 1," >> namelist.wps
      echo ${startdate} >> namelist.wps
      echo ${enddate} >> namelist.wps
      echo " interval_seconds = 3600" >> namelist.wps
      echo " io_form_geogrid = 2," >> namelist.wps
      echo "/" >> namelist.wps

      echo "&geogrid" >> namelist.wps
      echo " parent_id         = 1,  1," >> namelist.wps
      echo " parent_grid_ratio = 1,  3," >> namelist.wps
      echo " i_parent_start    = 1,  1," >> namelist.wps
      echo " j_parent_start    = 1,  1," >> namelist.wps
      echo " e_we              = ${grdpts_ew},  226," >> namelist.wps
      echo " e_sn              = ${grdpts_ns},  226," >> namelist.wps
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

      #@ anlys_hr = ${start_hr} - 1

        ### NEW LBCs                                                                                                                                                                                                                    
      if ( ${n} <= 9 ) then
           ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/1200/postprd_mem000$n/wrfnat_pert_hrrr_mem000${n}_0[3-9].grib2 ${HRRRE_DIR}/${event}/1200/postprd_mem000$n/wrfnat_pert_hrrr_mem000${n}_1[0-9].grib2 .
        else
           ${RUNDIR}/WRF_RUN/link_grib.csh ${HRRRE_DIR}/${event}/1200/postprd_mem00$n/wrfnat_pert_hrrr_mem00${n}_0[3-9].grib2 ${HRRRE_DIR}/${event}/1200/postprd_mem00$n/wrfnat_pert_hrrr_mem00${n}_1[0-9].grib2 .
        endif

      echo "Linked HRRRE grib files for member " $n

      @ n++

      cd ..

      else

      @ n++
 
      endif

end

###########################################################################
# UNGRIB
############################################################################

echo "#\!/bin/csh"                                                           >! ${RUNDIR}/ungrib_bc_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH' "-J ungrib_bc_mem"                                               >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH' "-o ${RUNDIR}/mem\%a/ungrib_bc_mem\%a.log"                       >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH' "-e ${RUNDIR}/mem\%a/ungrib_bc_mem\%a.err"                       >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH' "-A smallqueue"                                                >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH' "-p workq"                                                     >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH' "--ntasks-per-node=1"                                         >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH' "-n 1"                                                        >> ${RUNDIR}/ungrib_bc_mem.csh
echo '#SBATCH -t 1:30:00'                                                    >> ${RUNDIR}/ungrib_bc_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/ungrib_bc_mem.csh
echo " "                                                                     >> ${RUNDIR}/ungrib_bc_mem.csh
echo "set echo"                                                              >> ${RUNDIR}/ungrib_bc_mem.csh
echo "source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_d01"                            >> ${RUNDIR}/ungrib_bc_mem.csh
cat >> ${RUNDIR}/ungrib_bc_mem.csh << EOF
source ${TOP_DIR}/realtime.cfg.${event}

setenv MPICH_VERSION_DISPLAY 1
setenv MPICH_ENV_DISPLAY 1
setenv MPICH_MPIIO_HINTS_DISPLAY 1
setenv MPICH_GNI_RDMA_THRESHOLD 2048
setenv MPICH_GNI_DYNAMIC_CONN disabled
setenv MPICH_CPUMASK_DISPLAY 1
setenv OMP_NUM_THREADS 1
setenv MPI_SOFTWARE openmpi

cd ${RUNDIR}/mem\${SLURM_ARRAY_TASK_ID}

sleep 2

srun ${RUNDIR}/WRF_RUN/ungrib.exe

sleep 1

touch ${SEMA4}/ungrib_bc_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

sbatch --array=1-${HRRRE_BCS} ${RUNDIR}/ungrib_bc_mem.csh

while ( `ls -f ${SEMA4}/ungrib_bc_mem*_done | wc -l` != $HRRRE_BCS )
     echo "Waiting for ungribbing of GSD HRRRE Files"
     sleep 30
end

###########################################################################
# METGRID FOR ALL HRRRE MEMBERS
###########################################################################

set n = 1
while ( $n <= $HRRRE_BCS )
      cd mem${n}
      ln -sf ${RUNDIR}/geo_em.d01.nc ./geo_em.d01.nc
      @ n++
      cd ..
end

echo "#\!/bin/csh"                                                           >! ${RUNDIR}/metgrid_bc_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH' "-J metgrid_bc_mem"                                              >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH' "-o ${RUNDIR}/mem\%a/metgrid_bc_mem\%a.log"                      >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH' "-e ${RUNDIR}/mem\%a/metgrid_bc_mem\%a.err"                      >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH' "-A largequeue"                                                >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH' "-p workq"                                                     >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH' "--ntasks-per-node=24"                                        >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH' "-n 48"                                                       >> ${RUNDIR}/metgrid_bc_mem.csh
echo '#SBATCH -t 01:30:00'                                                   >> ${RUNDIR}/metgrid_bc_mem.csh
echo "#=================================================================="   >> ${RUNDIR}/metgrid_bc_mem.csh
echo " "                                                                     >> ${RUNDIR}/metgrid_bc_mem.csh
echo "set echo"                                                              >> ${RUNDIR}/metgrid_bc_mem.csh
echo "source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_d01"                            >> ${RUNDIR}/metgrid_bc_mem.csh
cat >> ${RUNDIR}/metgrid_bc_mem.csh << EOF
source ${TOP_DIR}/realtime.cfg.${event} 

setenv MPICH_VERSION_DISPLAY 1
setenv MPICH_ENV_DISPLAY 1
setenv MPICH_MPIIO_HINTS_DISPLAY 1
setenv MPICH_GNI_RDMA_THRESHOLD 2048
setenv MPICH_GNI_DYNAMIC_CONN disabled
setenv OMP_NUM_THREADS 1
setenv MPI_SOFTWARE openmpi

cd ${RUNDIR}/mem\${SLURM_ARRAY_TASK_ID}

sleep 2    
 
srun ${RUNDIR}/WRF_RUN/metgrid.exe 

sleep 1 

rm -fr mem*/GRIBFILE* mem*/HRRRE*

touch ${SEMA4}/metgrid_bc_mem\${SLURM_ARRAY_TASK_ID}_done

EOF

sbatch --array=1-${HRRRE_BCS} ${RUNDIR}/metgrid_bc_mem.csh

while ( `ls -f  ${SEMA4}/metgrid_bc_mem*_done | wc -l` != $HRRRE_BCS )
      echo "Waiting for metgrid to finish for $HRRRE_BCS members"
      sleep 30
end

echo "WPS is complete"

#rm geogrid.log geogrid.err geogrid.csh ungrib_bc_mem.csh metgrid_bc_mem.csh

#rm -fr mem*/GRIBFILE* mem*/HRRRE* mem*/metgrid.log*

###########################################################################
exit 0
###########################################################################
