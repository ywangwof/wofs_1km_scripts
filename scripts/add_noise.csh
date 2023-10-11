#!/bin/tcsh
##########################################################################
#
# Script Name: multivariate additive inflation
#
##########################################################################

# Will inherit from the parent script
#

#
# modules
#
module purge
module load compiler/latest
module load mkl/latest
module load hpcx-mt-ompi-intel-classic

setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/scratch/software/intel/netcdf/lib:/scratch/software/intel/hdf5/lib:/scratch/software/intel/grib2/lib:/scratch/software/miniconda3/lib:/usr/lib64

set verb=1

setenv CODE_ROOT  /scratch/ywang/wofs_1km/Multivariate_additive_inflation
setenv STATIC_DIR ${CODE_ROOT}/Static

#setenv OBS_ROOT   ${REF_DIR}

#setenv lh         '4000.0'
#setenv lv         '4000.0'
setenv qv_sd      '5.0'
setenv VS         '1.0'
setenv HZSCL      '0.9,1.0,1.1'
setenv HYDRONOISE '.true.'

if ($verb == 1) then
    echo "Entering add_noise ...."
endif

add_noise:

    set wrkdir  = $1
    set domstr  = $2
    set gdate   = $3

    set lh = "$4"
    set lv = "$5"

    set ENS_MEM   = $6
    set nprocs1   = $7
    set nprocs2   = $7

    if ( ! -e "${CODE_ROOT}" ) then
        echo "ERROR: CODE_ROOT=$CODE_ROOT not exists!"
        exit 1
    endif

    if ( ! -e "${wrkdir}" ) then
        echo "ERROR: WRKDIR=$wrkdir not exists!"
        exit 1
    endif

    if ( "${gdate}" == "" ) then
        echo "ERROR: ANALYSIS_TIME=$gdate is not defined!"
        exit 1
    endif

    if ( "${ENS_MEM}" == "" ) then
      echo "ERROR: ENS_MEM=$ENS_MEM is not defined!"
      exit 1
    endif

    if ( $verb == 1 ) then
        echo "CODE_ROOT = ${CODE_ROOT}"
        echo "WRKDIR    = ${wrkdir}"
        echo "ANALYSIS_TIME = ${gdate}"
        echo "ENS_MEM       = ${ENS_MEM}"
        if (${ENS_MEM} == 1) then
            echo "nprocs_MASKER = $nprocs1"
        endif
        echo "nprocs_ADDERR = $nprocs2"
        echo ""
    endif

    set YYYYMMDD = `echo $gdate | cut -c1-8`
    set HHMM     = `echo $gdate | cut -c9-12`

    set mywrkdir=${wrkdir}/add_noise/D${domstr}
    if ( ! -d ${mywrkdir} ) then
        mkdir -p ${mywrkdir}
    endif

    set WORK_ROOT = `dirname $wrkdir`
    set enkfdir   = "${WORK_ROOT}/enkfdir"
    set inputdir  = ${wrkdir}
    set inputfile = wrfinput_d$domstr

    cd ${mywrkdir}

    rm -rf *

    #-------------------------------------------------------------------
    # Prepare working files
    #-------------------------------------------------------------------

    #?WYH
    #RADAR_REF=${OBS_ROOT}/obsprd/refl_vol_lastcycle
    #RADAR_REF=${OBS_ROOT}/${YYYYMMDD}/obs_seq_RF_${YYYYMMDD}_${HHMM}.nc
    set RADAR_REF=${enkfdir}/dbzobs.nc

    set ANAVINFO=${STATIC_DIR}/anavinfo_arw_notlog_dbz_state_w_qc_exist_model_dbz_masker_UV_addnoise
    set BERROR=${STATIC_DIR}/gsi_be_dbz.gcv_UV_storm35_bin7
    set SATANGL=${STATIC_DIR}/global_satangbias.txt
    set SATINFO=${STATIC_DIR}/nam_regional_satinfo.txt
    set CONVINFO=${STATIC_DIR}/HRRRENS_regional_convinfo.txt
    set OZINFO=${STATIC_DIR}/global_ozinfo.txt
    set PCPINFO=${STATIC_DIR}/global_pcpinfo.txt
    set SCANINFO=${STATIC_DIR}/global_scaninfo.txt
    set OBERROR=${STATIC_DIR}/HRRRENS_errtable.r3dv
    cp  -f $ANAVINFO anavinfo
    ln -sf $BERROR   berror_stats
    ln -sf $SATANGL  satbias_angle
    ln -sf $SATINFO  satinfo
    ln -sf $CONVINFO convinfo
    ln -sf $OZINFO   ozinfo
    ln -sf $PCPINFO  pcpinfo
    ln -sf $SCANINFO scaninfo
    ln -sf $OBERROR  errtable
    #
    # Only need this file for single obs test
    #
    #bufrtable=${STATIC_DIR}/prepobs_prep.bufrtable
    #ln -sf $bufrtable ./prepobs_prep.bufrtable

    # for satellite bias correction
    ln -sf ${STATIC_DIR}/sample.satbias ./satbias_in
    #ln -sf ${enkfdir}/satbias_in ./satbias_in

    #-------------------------------------------------------------------
    # a) Run masker.exe [obtained by compiling sorc_masker] to get wrf_mask
    #    using any wrfinput_d01 file as the input. In wrf_mask, the QRAIN field
    #    tells the weak and strong storm binning, so that we can assign the
    #    proper static error statistics to corresponding locations in the following step (c).
    #    The weak and strong storm binning is distinguished by the observed
    #    reflectivity with a threshold of 35 dBZ.
    #-------------------------------------------------------------------

    while ( ! -e ${WORK_ROOT}/${gdate}/done_mask.D${domstr}.$gdate )
        if ( $ENS_MEM == 1) then
            # Set up some constants
            set MASK_EXE=${CODE_ROOT}/bin/masker.exe

            echo "a). Runing $MASK_EXE ...."
            echo "    Copy ${inputdir}/${inputfile} -> wrf_inout ...."
            cp ${inputdir}/${inputfile} wrf_inout

            echo "    Copy ${RADAR_REF} -> dbzobs.nc ...."
            cp ${RADAR_REF} dbzobs.nc

            set nmlfile=${STATIC_DIR}/gsiparm.anl_masker

            set sedfile=`mktemp -t wofserror.sed_XXXX`
            cat <<EOF > $sedfile
s/_LH_/${lh}/g
s/_LV_/${lv}/g
s/_VS_/${VS}/g
s/_HZSCL_/${HZSCL}/g
s/_DBZSD_/${qv_sd}/g
s/_HYDRO_/${HYDRONOISE}/g
s/refl_vol/dbzobs.nc/g
EOF
            sed -f $sedfile ${nmlfile} > gsiparm.anl
            rm -f $sedfile

            srun -n ${nprocs1} ${MASK_EXE} >& masker.D${domstr}.output
            if ( ! $? == 0 ) then
                echo "ERROR: program ${MASK_EXE}: status=$?"
                exit 1
            endif

            if ( $verb == 1 ) then
                echo "    mv wrf_inout --> ${WORK_ROOT}/${gdate}/wrf_mask.D${domstr}.$gdate"
            endif
            mv wrf_inout ${WORK_ROOT}/${gdate}/wrf_mask.D${domstr}.$gdate
            sleep 5
            touch ${WORK_ROOT}/${gdate}/done_mask.D${domstr}.$gdate
        else
            echo "Waiting for ${WORK_ROOT}/${gdate}/done_mask.D${domstr}.$gdate ...."
            sleep 5
        endif
    end

    #foreach m (`seq 1 $ENS_MEM`)
    set m = $ENS_MEM

        set memstr3  = `printf "%03d" ${m}`
        set iseed=`expr -1 \* ${m}`

    #-------------------------------------------------------------------
    # b) Run adderr_dbz.x [obtained by compiling sorc_pertdbz] to get wrf_pert
    #    using any wrfinput file and wrf_mask as the inputs. In wrf_pert,
    #    the QGRAUP field represents the perturbed reflectivity.
    #-------------------------------------------------------------------

        rm -f wrf_pert wrfinput_d01
        set ADDERRDBZ_EXE=${CODE_ROOT}/bin/adderr_dbz.x

        echo "b). Runing $ADDERRDBZ_EXE for member $m ...."
        echo "    Use ${WORK_ROOT}/${gdate}/wrf_mask.D${domstr}.$gdate as wrf_mask"

        #ln -sf ${WORK_ROOT}/${gdate}/wrf_mask.D${domstr}.$gdate ./wrf_mask
        #ln -sf ${WORK_ROOT}/${gdate}/wrf_mask.D${domstr}.$gdate ./gsi_wrf_inout.masker

        cp ${WORK_ROOT}/${gdate}/wrf_mask.D${domstr}.$gdate ./wrf_mask
        cp ${WORK_ROOT}/${gdate}/wrf_mask.D${domstr}.$gdate ./gsi_wrf_inout.masker

        ln -sf ${STATIC_DIR}/regcoeff.txt .

        echo "    Copy ${inputdir}/${inputfile} -> wrfinput_d01 ...."
        cp ${inputdir}/${inputfile} ./wrfinput_d01

        srun -n 1 ${ADDERRDBZ_EXE} $iseed $lh $lv $qv_sd
        if ( ! $? == 0 ) then
            echo "ERROR: program ${ADDERRDBZ_EXE}: status=$?"
            exit 1
        endif

        if ( $verb == 1 ) then
            echo ""
            echo "    mv wrfinput_d01 --> wrf_pert"
        endif
        mv wrfinput_d01 wrf_pert

    #-------------------------------------------------------------------
    # c) Run addinflation.x [obtained by compiling sorc_addinflation] to get
    #    perturbed file with analysis (to be perturbed), wrf_mask, and wrf_pert
    #    as inputs. See Subscripts/addnoise_new.ksh for more details on
    #    running addinflation.x
    #-------------------------------------------------------------------
        rm -f wrf_inout

        set ADDERR_EXE=${CODE_ROOT}/bin/addinflation.x

        echo "c). Runing $ADDERR_EXE for member $m ...."

        echo "    Copy ${inputdir}/${inputfile} -> wrf_inout ...."
        cp ${inputdir}/${inputfile} wrf_inout

        if ( ! -e dbzobs.nc ) then
            echo "    Copy ${RADAR_REF} -> dbzobs.nc ...."
            cp ${RADAR_REF} dbzobs.nc
        endif

        set nmlfile=${STATIC_DIR}/addnoise.nml

        set sedfile=`mktemp -t wofserror_${memstr3}.sed_XXXX`
        cat <<EOF > $sedfile
s/_SEED_/${iseed}/g
s/_LH_/${lh}/g
s/_LV_/${lv}/g
s/_VS_/${VS}/g
s/_HZSCL_/${HZSCL}/g
s/_DBZSD_/${qv_sd}/g
s/_HYDRO_/${HYDRONOISE}/g
s/refl_vol/dbzobs.nc/g
EOF
        sed -f $sedfile ${nmlfile} > gsiparm.anl
        rm -f $sedfile

        srun -n ${nprocs2} ${ADDERR_EXE} >& adderr.output_D${domstr}
        set istatus=$?
        if ( $istatus != 0 ) then
            echo "ERROR: program ${ADDERR_EXE}: status = $istatus."
            echo "       output file is $cwd/adderr.output_D${domstr}"
            exit $istatus
        endif

        if ( $verb == 1 ) then
            echo ""
            echo "    mv ${inputdir}/${inputfile} --> ${inputfile}_unpert"
            mv ${inputdir}/${inputfile} ${inputfile}_unpert
            echo "    cp wrf_inout --> ${inputfile}_pert"
            cp wrf_inout ${inputfile}_pert
        endif

        if ( $verb == 1 ) then
            echo "    mv wrf_inout --> ${inputdir}/${inputfile}"
        endif
        mv wrf_inout ${inputdir}/${inputfile}

    #end

    #-------------------------------------------------------------------

    cd $wrkdir

    #
    # Clean working directory
    #
    if ( ! $verb == 1 ) then
        rm -rf $mywrkdir;
    endif

exit $istatus
