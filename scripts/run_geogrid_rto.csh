#!/bin/csh -f
#
#-----------------------------------------------------------------------
# Script Nested_WPS.csh
#
# Purpose: Run WPS to generate input files 
#
#-----------------------------------------------------------------------

set echo
#source ~/.bashrc
source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_rto_d01
source ${TOP_DIR}/retro.cfg.${event}
source ${CENTRALDIR}/radar_files/radars.${event}.csh

cd ${RUNDIR}

if ( -f namelist.wps ) then
  rm -rf ${RUNDIR}/namelist.wps
endif

rm -fr geo_em.d0*.nc geogrid.log.00*

set startdate = " start_date = '${sdate}', '${sdate}',"
set enddate = " end_date = '${edate}', '${edate}',"

#cp -f ${TEMPLATE_DIR}/namelist.wps.template.conv.${event} .
cp ${TEMPLATE_DIR}/namelist.wps.template.HRRRE .

if ( -e namelist.wps ) rm -f namelist.wps

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
#echo " geog_data_res     = 'modis_15s+modis_fpar+modis_lai+30s', 'modis_15s+modis_fpar+modis_lai+30s'," >> namelist.wps
echo " geog_data_res     = 'bnu_soil_30s+modis_15s_lakes+maxsnowalb_modis+albedo_modis+modis_lai', 'modis_15s+modis_fpar+modis_lai+30s'," >> namelist.wps
echo " dx = 3000," >> namelist.wps
echo " dy = 3000," >> namelist.wps
echo " map_proj = 'lambert'," >> namelist.wps
echo " ref_lat   =  ${cen_lat}," >> namelist.wps
echo " ref_lon   =  ${cen_lon}," >> namelist.wps
echo " truelat1  =  30.00," >> namelist.wps
echo " truelat2  =  60.00," >> namelist.wps
echo " stand_lon =  ${cen_lon}," >> namelist.wps
echo " geog_data_path = '/scratch/wofuser/realtime/geog'" >> namelist.wps
echo " opt_geogrid_tbl_path = '${TEMPLATE_DIR}'" >> namelist.wps
echo "/" >> namelist.wps

cat namelist.wps.template.HRRRE >> namelist.wps

###########################################################################
# GEOGRID
###########################################################################

echo "#\!/bin/csh"                                                            >! ${RUNDIR}/geogrid.csh
echo "#=================================================================="    >> ${RUNDIR}/geogrid.csh
echo '#SBATCH' "-J geogrid"                                                   >> ${RUNDIR}/geogrid.csh 
echo '#SBATCH' "-o ${RUNDIR}/geogrid.log"                                     >> ${RUNDIR}/geogrid.csh
echo '#SBATCH' "-e ${RUNDIR}/geogrid.err"                                     >> ${RUNDIR}/geogrid.csh
echo '#SBATCH' "-p batch"                                                     >> ${RUNDIR}/geogrid.csh
echo '#SBATCH' "--ntasks-per-node=24"                                         >> ${RUNDIR}/geogrid.csh
echo '#SBATCH' "-n 24"                                                        >> ${RUNDIR}/geogrid.csh
echo '#SBATCH' '-t 00:10:00'                                                  >> ${RUNDIR}/geogrid.csh
echo "#================================================================="     >> ${RUNDIR}/geogrid.csh
echo " "                                                                      >> ${RUNDIR}/geogrid.csh
echo "set echo"                                                               >> ${RUNDIR}/geogrid.csh
echo "source /scratch/wofs_1km/wofs_1km_scripts/WOFenv_rto_d01"                                            >> ${RUNDIR}/geogrid.csh
echo "source ${TOP_DIR}/retro.cfg.${event}"                                   >> ${RUNDIR}/geogrid.csh
cat >> ${RUNDIR}/geogrid.csh << EOF

cd ${RUNDIR}

echo "Running geogrid.exe"

srun --mpi=pmi2 ${RUNDIR}/WRF_RUN/geogrid.exe

echo "Geogrid is complete."

touch ${SEMA4}/geogrid_done
EOF

chmod +x geogrid.csh

sbatch ${RUNDIR}/geogrid.csh

###########################################################################
exit 0
###########################################################################
