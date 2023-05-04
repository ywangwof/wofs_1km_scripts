##########################

Sequence of scripts to run nested 1-km WoFS

##########################

First, create nested domain in /scratch/wofs_1km/grid_setup
using Create_WOFS_Grid.csh

 - edit event and nest starting point in Create_WOFS_Grid.csh
 
##########################

Create radar files for 3-km parent domain in /scratch/wofs_1km/wofs-obs-radar-parent

 - run create_radar_obs.csh (this should be done using a crontab automatically each day)

Create radar files for 1-km nest domain in /scratch/wofs_1km/wofs-obs-radar-nest

 - run create_radar_obs.csh  *** change the event date ***

#########################

Scripts below are in /scratch/wofs_1km/wofs_1km_scripts/

Paths are set to run in the shared /scratch/wofs_1km directory

No paths need be changed from user-to-user

FOR PSEUDO-RT (we'll be using the "_rto" files in 2023):

 WPS and real.exe:

 1) ./Setup_parent.csh and ./Setup_nest.csh 

 2) ./run_geogrid.csh

 3) ./run_ungrib_metgrid_BC.csh

 4) ./run_ungrib_metgrid_IC.csh

 5) ./create_IC.csh

 6) ./create_BC.csh

 DA cycling for both domains:

 7) ./Run_WOFS_parent.csh and ./Run_WOFS_nest.csh (execute these at the same
    time; their progressions are dependent on one another)

 Ensemble forecasts:
 
 8) ./Run_FCST00.csh (only top of hour forecasts)

FOR RETRO RUNS:

 Same workflow but for files with "_rto..." in name
  - must edit the event in WOFenv_rto_d01 and WOFenv_rto_d02 first
  - must also edit the event info in Setup_parent_rto.csh and Setup_nest_rto.csh


CFL Errors:

    - If the model time step must be lowered due to CFL errors, be sure to lower it in increments of 3 s (for example, from 12 s to 9 s) since it has to be divisible by 3 for the nest
    - If the 3-hr forecast time step (fts) must be lowered from 12 s, it must be decreased to 6 s because a 9 s time step here will not produce parent domain wrfwof files at the appropriate 
      times since the output is every 5 min 
