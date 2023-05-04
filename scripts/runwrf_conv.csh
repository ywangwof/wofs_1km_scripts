#!/bin/csh 

set mem=${1}
set starttime=${2}
set endtime=${3}
set retrofile=${4}
source ${retrofile}
source /scratch/wofs_1km/radar_files/radars.${event}.csh

set START_YEAR  = `echo ${starttime} | cut -c1-4`
set START_MONTH = `echo ${starttime} | cut -c5-6`
set START_DAY   = `echo ${starttime} | cut -c7-8`
set START_HOUR  = `echo ${starttime} | cut -c9-10`
set START_MIN   = `echo ${starttime} | cut -c11-12`

set END_YEAR  = `echo ${endtime} | cut -c1-4`
set END_MONTH = `echo ${endtime} | cut -c5-6`
set END_DAY   = `echo ${endtime} | cut -c7-8`
set END_HOUR  = `echo ${endtime} | cut -c9-10`
set END_MIN   = `echo ${endtime} | cut -c11-12`

echo ${END_HOUR}

set WRFRUNDIR=${RUNDIR}/enkfrun${mem}

      ${REMOVE} advModel.sed namelist.input
      cat >! advModel.sed << EOF
         /run_hours/c\
         run_hours                  = 0,
         /run_minutes/c\
         run_minutes                = ${cycleinterval},
         /run_seconds/c\
         run_seconds                = 0,
         /start_year/c\
         start_year                 = 2*${START_YEAR},
         /start_month/c\
         start_month                = 2*${START_MONTH},
         /start_day/c\
         start_day                  = 2*${START_DAY},
         /start_hour/c\
         start_hour                 = 2*${START_HOUR},
         /start_minute/c\
         start_minute               = 2*${START_MIN},
         /start_second/c\
         start_second               = 2*00,
         /end_year/c\
         end_year                   = 2*${END_YEAR},
         /end_month/c\
         end_month                  = 2*${END_MONTH},
         /end_day/c\
         end_day                    = 2*${END_DAY},
         /end_hour/c\
         end_hour                   = 2*${END_HOUR},
         /end_minute/c\
         end_minute                 = 2*${END_MIN},
         /end_second/c\
         end_second                 = 2*00,
         /fine_input_stream/c\
         fine_input_stream          = 2*0,
         /history_interval/c\
         history_interval           = 2*${cycleinterval},
         /frames_per_outfile/c\
         frames_per_outfile         = 2*1,
         /auxhist2_interval/c\
         auxhist2_interval          = 2*${cycleinterval}, 
         /diag_print/c\
         diag_print                 = 0,
         /time_step_fract_num/c\
         time_step_fract_num        = 0,
         /time_step_fract_den/c\
         time_step_fract_den        = 1,
         /max_dom/c\
         max_dom                    = 2,
         /debug_level/c\
         debug_level                = 0,
         /e_we/c\
         e_we                       = ${grdpts_ew}, ${grdpts_ew2},
         /e_sn/c\
         e_sn                       = ${grdpts_ns}, ${grdpts_ns2},
         /i_parent_start/c\
         i_parent_start             = 0, ${nest_i},
         /j_parent_start/c\
         j_parent_start             = 0, ${nest_j},
         /parent_time_step_ratio/c\
         parent_time_step_ratio     = 1, 3,
         /parent_grid_ratio/c\
         parent_grid_ratio          = 1, 3,
         / time_step /c\
         time_step                  = ${ts},
         /numtiles/c\
         numtiles                   = ${tiles},
         /nproc_x/c\
         nproc_x                    = $procx,
         /nproc_y/c\
         nproc_y                    = $procy,
         /radt/c\
         radt                       = 5, 1,
         /num_land_cat/c\
         num_land_cat               = 20,
EOF
# The EOF on the line above MUST REMAIN in column 1.

${COPY} -f ${TEMPLATE_DIR}/namelists.WOFS.nested/namelist.input.member${mem} ${WRFRUNDIR}/
sed -f advModel.sed ${WRFRUNDIR}/namelist.input.member${mem} >! ${WRFRUNDIR}/namelist.input

${COPY} ${ENKFDIR}/wrfbdy_d01.${mem} ${WRFRUNDIR}/wrfbdy_d01
sleep 1
${COPY} -f ${RUNDIR}/${starttime}/wrfinput_d01.${mem} ${WRFRUNDIR}/wrfinput_d01
sleep 1
${COPY} -f ${CENTRALDIR}/D02/${event}/${starttime}/wrfinput_d02.${mem} ${WRFRUNDIR}/wrfinput_d02
sleep 1
#${COPY} -f ${RUNDIR}/ic${mem}/wrfinput_d01_ic ${WRFRUNDIR}/wrfinput_d01
#${COPY} -f ${CENTRALDIR}/D02/${event}/ic${mem}/wrfinput_d02_ic ${WRFRUNDIR}/wrfinput_d02
${LINK} ${RUNDIR}/WRF_RUN/* ${WRFRUNDIR}

exit 0

########################################################################
