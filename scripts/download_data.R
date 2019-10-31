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
if(length(list.files(lc_dir, pattern="\\.tif$"))==0 ){
  system(sprintf("wget -O %s  https://www.dropbox.com/s/sknwdxyxmwt1jux/land_use.zip", paste0(lc_dir,'landuse_maps.zip')))
  system(sprintf("unzip -o %s -d %s ",paste0(lc_dir,'landuse_maps.zip'),lc_dir))
  system(sprintf("rm %s",paste0(lc_dir,'landuse_maps.zip')))
}

## project area boundaries shapefile
if((length(list.files(gadm_dir, pattern="\\.shp$"))==0)){
system(sprintf("wget -O %s  https://www.dropbox.com/s/orjchiihat6hu0b/cocoa_project_area_ghana.zip", paste0(gadm_dir,'cocoa_project_area_ghana.zip')))
system(sprintf("unzip -o %s -d %s ",paste0(gadm_dir,'cocoa_project_area_ghana.zip'),gadm_dir))
system(sprintf("rm %s",paste0(gadm_dir,'cocoa_project_area_ghana.zip')))
}
## project area boundaries raster
if(!file.exists(paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.tif"))){
  system(sprintf("wget -O %s  https://www.dropbox.com/s/s3qt2t1ilpcp9ho/cocoa_project_ghana_30nutm_dissolved.tif",paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.tif")))
}
## 1km grid for sample design
if(!file.exists(paste0(samp_dir,"Grid_Ghana_1000m_1_subgrid.csv"))){
  system(sprintf("wget -O %s  https://www.dropbox.com/s/7mvxne8a5mq6jyk/Grid_Ghana_1000m_1_subgrid.csv",paste0(samp_dir,"Grid_Ghana_1000m_1_subgrid.csv")))
}
## the samples assessed using Collect Earth for africa deal
if(!file.exists(paste0(samp_dir,"africa_deal_ghana.csv"))){
  system(sprintf("wget -O %s  https://www.dropbox.com/s/9uze8sx524h6kn7/africa_deal_ghana.csv",paste0(samp_dir,"africa_deal_ghana.csv")))
}

## bfast results
if(length(list.files(bfst_res_dir, pattern="\\.tif$"))==0 ){
  system(sprintf("wget -O %s    https://www.dropbox.com/s/34ny1dx1jqea7i5/final_results_O_1_H_ROC_T_OC_F_h_Overall_2000_2005_2014_.zip",paste0(bfst_res_dir,"final_results_O_1_H_ROC_T_OC_F_h_Overall_2000_2005_2014_.zip")))
  system(sprintf("unzip -o %s -d %s ",paste0(bfst_res_dir,'final_results_O_1_H_ROC_T_OC_F_h_Overall_2000_2005_2014_.zip'),bfst_res_dir))
  system(sprintf("rm %s",paste0(bfst_res_dir,'final_results_O_1_H_ROC_T_OC_F_h_Overall_2000_2005_2014_.zip')))
}
# landtrendr closed forest only deforestation
if(length(list.files(lndtrndr_dir, pattern="\\closed_forest*"))==0){
  system(sprintf("wget -O %s      https://www.dropbox.com/s/pbba9z5qipkqv6x/export_landtrendr_deforested_closed_forest.zip",paste0(lndtrndr_dir,"export_landtrendr_deforested_closed_forest.zip")))
  system(sprintf("unzip -o %s -d %s ",paste0(lndtrndr_dir,'export_landtrendr_deforested_closed_forest.zip'),lndtrndr_dir))
  system(sprintf("rm %s",paste0(lndtrndr_dir,'export_landtrendr_deforested_closed_forest.zip')))
}

if(length(list.files(lndtrndr_dir, pattern="\\deforested.tif$"))==0){
  system(sprintf("wget -O %s      https://www.dropbox.com/s/kxv9yx76252pnr7/export_landtrendr_deforested.zip",paste0(lndtrndr_dir,"export_landtrendr_deforested.zip")))
  system(sprintf("unzip -o %s -d %s ",paste0(lndtrndr_dir,'export_landtrendr_deforested.zip'),lndtrndr_dir))
  system(sprintf("rm %s",paste0(lndtrndr_dir,'export_landtrendr_deforested.zip')))
}


# if(!file.exists()){}

