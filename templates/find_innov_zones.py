import numpy as np
from numpy import *
import netCDF4 as ncdf
#from news_e_post_cbook_v2 import *

def calc_variance(var, ne):
  # See description in news_e_post_cbook_v2.py

  var_mean = np.mean(var,axis=0)
  var_diff = var[:,] - var_mean

  ens_var = (np.sum(var_diff**2,axis=0) / ne)**.5
  var_ngbh = np.zeros((len(ens_var[:,0]),len(ens_var[0,:])))

  for i in range(2,len(ens_var[0,:])-2,5):
   for j in range(2,len(ens_var[:,0])-2,5):
    neighborhood_avg = np.mean(ens_var[j-2:j+3,i-2:i+3])
    var_ngbh[j-2:j+3,i-2:i+3] = neighborhood_avg

  var_ngbh[var_ngbh < 2.0] = 0
  return var_ngbh

def calc_innov(innov,ny,nx):

  var_ngbh = np.zeros((ny,nx))
  for i in range(12,nx-22,5):
   for j in range(12,ny-22,5):
    neighborhood_avg = np.amax(innov[j-2:j+3,i-2:i+3])
    var_ngbh[j-2:j+3,i-2:i+3] = neighborhood_avg

  var_ngbh[isnan(var_ngbh)] = 0.0
  var_ngbh[var_ngbh < 20.0] = 0.0
  print(np.amax(var_ngbh))
  return var_ngbh  

##Set some variables including center of domain

ne = 36
ny = 250
nx = 250
latmin = []
latmax = []
lonmin = []
lonmax = []
set_3km = []
set_5km = []
lat_test = []

w_up = np.zeros((ne,ny,nx))
refl = np.zeros((ne,ny-20,nx-20)) #chop off boundaries

for n in range(0,ne):
  ens = str(n+1)
  fx = ncdf.Dataset('./advance_temp'+ens+'/wrfinput_d01')
  w_up[n,:,:] = fx.variables["W_UP_MAX"][0,:,:]
  refl[n,:,:] = fx.variables["REFL_10CM"][0,16,9:-11,9:-11]

  if (n==0):
     xlat = fx.variables["XLAT"][0,:,:]                     #latitude (dec deg; Lambert conformal)                                                                                                     
     xlon = fx.variables["XLONG"][0,:,:]    

refl_mean = np.mean(refl,axis=0)
fo = ncdf.Dataset('./obs_refl.nc')
dz_obs = fo.variables["gridded_observations"]

innov = np.abs(dz_obs - refl_mean)
w_var = calc_variance(w_up, ne)
w_var[w_var < 2.0] = 0

dz_innov = calc_innov(innov,ny,nx)

for i in range(0, len(w_var[0,:]), 5):
 for j in range(0, len(w_var[:,0]), 5):
  if w_var[j,i] > 0 or dz_innov[j,i] > 0:
   latmin.append(xlat[j,i])
   latmax.append(xlat[j+4,i+4]) 
   lonmin.append(xlon[j,i])
   lonmax.append(xlon[j+4,i+4])

obs_file_3km = ncdf.Dataset('./obs_epoch_3km.nc')

obs_loc3 = obs_file_3km.variables['location']
num_obs3 = len(obs_loc3[:,0])

for obs in range(0,num_obs3):
   location3 = obs_loc3[obs,:]
   lat3 = location3[1]
   lon3 = location3[0]-360.0

   for i in range(0,len(latmin)):

    if lat3 >= latmin[i] and lat3 <= latmax[i] and lon3 >= lonmin[i] and lon3 <= lonmax[i]:     #Find 3 km obs in high variance area
     set_3km.append(obs+1)
     lat_test.append(lat3)
     lat_test.append(lon3)
     break  
     
fout = ncdf.Dataset('./obs_mask.nc',"w")

fout.createDimension('3km_obs_num', len(set_3km))
fout.createDimension('3km_lat_test',len(lat_test))

obs_3km_var = fout.createVariable('3_km_obs_assim', 'f4', ('3km_obs_num',))
obs_3km_var.long_name = "3 km observations to assimilate"
obs_3km_var.units = "Obs Number"

lat_3km_var = fout.createVariable('3_km_obs_latlon', 'f4', ('3km_lat_test',))
lat_3km_var.long_name = "3 km observations to assimilate"
lat_3km_var.units = "Obs Number"

fout.variables['3_km_obs_assim'][:] = set_3km
fout.variables['3_km_obs_latlon'][:] = lat_test

fout.close()

print('starting mask')
file_3km = 'obs_seq_3km.out'
#file_5km = 'obs_seq_5km.out'

m = -1
lines3 = open(file_3km, 'r').readlines()
#lines5 = open(file_5km, 'r').readlines()
text = '   1000.00000000000\n'

print('starting 3 km')
with open(file_3km) as f:

 for i in range(1,num_obs3+1):
  fdum = f
  if i not in set_3km:
   if i < 10:
    phrase=' OBS            '+str(i)
   if i >= 10 and i < 100:
    phrase=' OBS           '+str(i)
   if i >= 100 and i < 1000:
    phrase=' OBS          '+str(i)
   if i >= 1000 and i < 10000:
    phrase=' OBS         '+str(i)
   if i >= 10000 and i < 100000:
    phrase=' OBS        '+str(i)
   if i >= 100000 and i < 1000000:
    phrase=' OBS       '+str(i)
   if i >= 1000000 and i < 10000000:
    phrase=' OBS      '+str(i)

   for line in f:
     m += 1
     if phrase in line:
      line_num = m
      break

   if line_num >= 0: lines3[line_num+2] = text

out = open(file_3km, 'w')
out.writelines(lines3)
out.close()

open("mask_obs_done","w")
