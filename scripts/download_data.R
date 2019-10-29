######################################################
##   download data for BFAST workshop               ##
##  and activity data working session  October 2019 ##
######################################################

####################################################################################################
####################################################################################################
## DOWNLOAD DATA
## Contact yelena.finegold@fao.org
####################################################################################################
####################################################################################################

## user parameters to get directory names
source('~/ghana_bfast_landtrendR/scripts/s0_parameters.R')
## download data 

### land cover maps from 2000,2010,2013,2015,2018
system(sprintf("wget -O %s  https://www.dropbox.com/s/sknwdxyxmwt1jux/land_use.zip", paste0(lc_dir,'landuse_maps.zip')))
system(sprintf("unzip -o %s -d %s ",paste0(lc_dir,'landuse_maps.zip'),lc_dir))
system(sprintf("rm %s",paste0(lc_dir,'landuse_maps.zip')))


## project area boundaries shapefile
system(sprintf("wget -O %s  https://www.dropbox.com/s/orjchiihat6hu0b/cocoa_project_area_ghana.zip", paste0(gadm_dir,'cocoa_project_area_ghana.zip')))
system(sprintf("unzip -o %s -d %s ",paste0(gadm_dir,'cocoa_project_area_ghana.zip'),gadm_dir))
system(sprintf("rm %s",paste0(gadm_dir,'cocoa_project_area_ghana.zip')))

## project area boundaries raster
system(sprintf("wget -O %s  https://www.dropbox.com/s/s3qt2t1ilpcp9ho/cocoa_project_ghana_30nutm_dissolved.tif",paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.tif")))

## 1km grid for sample design
system(sprintf("wget -O %s  https://www.dropbox.com/s/7mvxne8a5mq6jyk/Grid_Ghana_1000m_1_subgrid.csv",paste0(samp_dir,"Grid_Ghana_1000m_1_subgrid.csv")))

## the samples assessed using Collect Earth for africa deal
system(sprintf("wget -O %s  https://www.dropbox.com/s/9uze8sx524h6kn7/africa_deal_ghana.csv",paste0(samp_dir,"africa_deal_ghana.csv")))

