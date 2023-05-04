#!/usr/bin/python
#
# Example) 40 member ensemble at 2315 UTC
# make_dir.py 41 23 15

import sys, shutil, string, time, os, dircache, glob

inputdir = '/home/dstratma/GSI_code/scripts/Templates/namelists.WOFS.1km'
number_of_ensemble = 36

#how to add new variables to namelists
#sed -i '/mosaic_lu/ i\ sf_surface_mosaic                   = 1,' namelist.input.member*
#
##################################
os.chdir(inputdir)
#------------------------------------------------------------------
# link met_em* files from WPS directory
#------------------------------------------------------------------

for nen in range (1,number_of_ensemble+1):
    #ensnamelist = inputdir + "/backup/namelist.input.member%d"%nen
    #ensnamelist = inputdir + "/real/namelist.input.member%03d"%nen
# copy namelist.input
    org_input = inputdir + '/orig/namelist.input.member%d'%nen
    out_input = inputdir + '/namelist.input.member%d'%nen

    shinput = open(org_input,'r')
    inshlns = shinput.readlines()
    shinput.close()

    #endtime = hour * 60 + minute + 10  #wrf.exe
    #e_hour, e_min = divmod(endtime, 60)
    #interval = (1* 60  - minute)*60
    for i in range(len(inshlns)):
        #if(inshlns[i].find("run_hours") > 0):
        #    inshlns[i] =  " run_hours                           = 0,    \n"
        #if(inshlns[i].find("run_minutes") > 0):
        #    inshlns[i] =  " run_minutes                         = 10,    \n"
        #if(inshlns[i].find("end_minute") > 0):
        #    inshlns[i] =  " end_minute                          = %02d,    \n"%e_min
        #if(inshlns[i].find("interval_seconds") > 0):
        #    inshlns[i] =  " interval_seconds                    = %d,    \n"%interval
        #if(inshlns[i].find("history_interval ") > 0):
        #    inshlns[i] =  " history_interval                    = 5,    \n"
        #if(inshlns[i].find("debug_level ") > 0):
        #    inshlns[i] =  " output_ready_flag                   = .true.,  \n" + \
        #                  " debug_level                         = 0,    \n"
        #if(inshlns[i].find("time_step ") > 0):
        #    inshlns[i] =  " time_step                           = 3,    \n"
        #if(inshlns[i].find("numtiles ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("nproc_x ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("nproc_y ") > 0):
        #    inshlns[i] =  ""
        if(inshlns[i].find("sf_surface_physics ") > 0):
            inshlns[i] =  " sf_surface_physics                  = 4, 4,    \n"
        if(inshlns[i].find("num_soil_layers ") > 0):
            inshlns[i] =  " num_soil_layers                     = 4,    \n"
        if(inshlns[i].find("num_land_cat ") > 0):
            inshlns[i] =  " num_land_cat                        = 21,    \n"
        if(inshlns[i].find("sf_surface_mosaic ") > 0):
            inshlns[i] =  " sf_surface_mosaic                   = 1,    \n"
        if(inshlns[i].find("mosaic_lu ") > 0):
            inshlns[i] =  " mosaic_lu                           = 0,    \n"
        if(inshlns[i].find("mosaic_soil ") > 0):
            inshlns[i] =  " mosaic_soil                         = 0,    \n"
        #if(inshlns[i].find("p_top_requested ") > 0):
        #    inshlns[i] =  " p_top_requested                     = 1500,    \n"
        #if(inshlns[i].find("max_dom ") > 0):
        #    inshlns[i] =  " max_dom                             = 1,    \n"
        #if(inshlns[i].find("parent_id ") > 0):
        #    inshlns[i] =  " parent_id                           = 0,    \n"
        #if(inshlns[i].find("i_parent_start ") > 0):
        #    inshlns[i] =  " i_parent_start                      = 1,    \n"
        #if(inshlns[i].find("j_parent_start ") > 0):
        #    inshlns[i] =  " j_parent_start                      = 1,    \n"
        #if(inshlns[i].find("sf_surface_physics ") > 0):
        #    inshlns[i] =  " sf_surface_physics                  = 2, 4,    \n"
        #if(inshlns[i].find("fine_input_stream ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("io_form_auxinput2 ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("nwp_diagnostics ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("all_ic_times ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("lagrange_order ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("interp_type ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("lowest_lev_from_sfc ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("force_sfc_in_vinterp ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("zap_close_levels ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("use_levels_below_ground ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("reorder_mesh ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("mp_physics ") > 0):
        #    inshlns[i] =  " mp_physics                          = 8,    \n"
        #if(inshlns[i].find("nssl_alphar ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("nssl_alphah ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("nssl_ehw0 ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("nssl_ehlw0 ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("nssl_cccn ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("sst_update ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("lagday ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("hailcast_opt ") > 0):
        #    inshlns[i] =  ""
        #if(inshlns[i].find("opt_sfc ") > 0):
        #    inshlns[i] =  ""
        if(inshlns[i].find("/") > 0):
            inshlns[i] =  " /\n"  
 
    shoutput = open(out_input,'w')
    shoutput.writelines(inshlns)
    shoutput.close()

