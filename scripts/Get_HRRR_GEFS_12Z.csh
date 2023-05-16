#!/bin/csh

setenv HRRRE_DIR /scratch/wofs_1km/MODEL_DATA/HRRRE
setenv event `date +%Y%m%d`
#setenv event 20230419

mkdir -p ${HRRRE_DIR}/${event} ; mkdir -p ${HRRRE_DIR}/${event}/1200

cd ${HRRRE_DIR}/${event}/1200

scp Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/HRRR_GEFS_ready ./HRRR_GEFS_ready

while ( ! -e HRRR_GEFS_ready )

      sleep 60

      scp Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/HRRR_GEFS_ready ./HRRR_GEFS_ready

end

foreach mem ( 1 2 3 4 5 6 7 8 9 )

mkdir ${HRRRE_DIR}/${event}/1200/postprd_mem000${mem}

echo "#\!/bin/csh"                                                           >! ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh

cat >> ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh << EOF

rsync -arq --include="wrfnat_pert_hrrr_mem000${mem}_0[0-9].grib2" --exclude="*" Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/postprd_mem000${mem}/ ${HRRRE_DIR}/${event}/1200/postprd_mem000${mem}

rsync -arq --include="wrfnat_pert_hrrr_mem000${mem}_1[0-9].grib2" --exclude="*" Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/postprd_mem000${mem}/ ${HRRRE_DIR}/${event}/1200/postprd_mem000${mem}

rsync -arq --include="wrfnat_pert_hrrr_mem000${mem}_2[0-5].grib2" --exclude="*" Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/postprd_mem000${mem}/ ${HRRRE_DIR}/${event}/1200/postprd_mem000${mem}

sleep 1

exit (0)

EOF

chmod +x ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh
${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh >&! ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.log &

sleep 1

end

while ( `ls -f ${HRRRE_DIR}/${event}/1200/postprd_mem*/wrfnat* | wc -l` != 234 )

      sleep 10
      echo "Waiting for the HRRR_GEFS members 1-9 to transfer"

end

foreach mem ( 10 11 12 13 14 15 16 17 18 )

mkdir ${HRRRE_DIR}/${event}/1200/postprd_mem00${mem}

echo "#\!/bin/csh"                                                           >! ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh

cat >> ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh << EOF

rsync -arq --include="wrfnat_pert_hrrr_mem00${mem}_0[0-9].grib2" --exclude="*" Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/postprd_mem00${mem}/ ${HRRRE_DIR}/${event}/1200/postprd_mem00${mem}

rsync -arq --include="wrfnat_pert_hrrr_mem00${mem}_1[0-9].grib2" --exclude="*" Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/postprd_mem00${mem}/ ${HRRRE_DIR}/${event}/1200/postprd_mem00${mem}

rsync -arq --include="wrfnat_pert_hrrr_mem00${mem}_2[0-5].grib2" --exclude="*" Christopher.Kerr@dtn-jet.boulder.rdhpcs.noaa.gov:/lfs1/BMC/wrfruc/WoF_BC/pert_hrrr/${event}12/postprd_mem00${mem}/ ${HRRRE_DIR}/${event}/1200/postprd_mem00${mem}

sleep 1

exit (0)

EOF

chmod +x ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh
${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.csh >&! ${HRRRE_DIR}/${event}/1200/HRRRE_mem${mem}.log &

sleep 1

end

while ( `ls -f ${HRRRE_DIR}/${event}/1200/postprd_mem*/wrfnat* | wc -l` != 468 )

      sleep 10
      echo "Waiting for the HRRR_GEFS members 10-18 to transfer"

end

touch ${HRRRE_DIR}/${event}/1200/HRRRE_12BCs_ready

exit (0)

