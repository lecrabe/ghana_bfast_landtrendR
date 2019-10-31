##########################################################################################
################## Read, manipulate and write raster data
##########################################################################################

########################################################################################## 
# Contact: remi.dannunzio@fao.org 
# Modified by yelena.finegold@fao.org
# Last update: 2019-10-17
##########################################################################################

time_start  <- Sys.time()

# LOAD PARAMETERS
source('~/ghana_bfast_landtrendR/scripts/s0_parameters.R')

####################################################################################
####### DOWNLOAD HANSEN DATA
####################################################################################

startyear1 <- as.numeric(paste0(strsplit(toString(startyear),"")[[1]][3:4],collapse = ""))
endyear1 <-  as.numeric(paste0(strsplit(toString(endyear),"")[[1]][3:4],collapse = ""))

### Make vector layer of tiles that cover the country
aoi   <- getData('GADM',
                 path=gfcstore_dir, 
                 country= countrycode, 
                 level=0)

bb    <- extent(aoi)

tiles <- calc_gfc_tiles(aoi)

proj4string(tiles) <- proj4string(aoi)
tiles <- tiles[aoi,]

# Check to see if these tiles are already present locally, and download them if 
# they are not.
download_tiles(tiles, gfcstore_dir)


### MERGE THE TILES TOGETHER, FOR EACH LAYER SEPARATELY and CLIP TO THE BOUNDING BOX OF THE COUNTRY
prefix <- "Hansen_GFC-2018-v1.6_"
tiles  <- list.files(gfcstore_dir,pattern = paste0(prefix,'datamask'))
tilesx <- substr(tiles,31,38)

types <- c("treecover2000","lossyear","gain","datamask")
for(type in types){
  if(!file.exists(paste0(gfc_dir,"gfc_",type,".tif"))){
  print(type)
  
  to_merge <- paste(prefix,type,"_",tilesx,".tif",sep = "")
  
  system(sprintf("gdal_merge.py -o %s -v %s",
                 paste0(gfc_dir,"tmp_merge_",type,".tif"),
                 paste0(gfcstore_dir,to_merge,collapse = " ")
  ))
  
  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 paste0(gfc_dir,"tmp_merge_",type,".tif"),
                 paste0(gfc_dir,"gfc_",type,".tif")
  ))
  
  system(sprintf("rm %s",
                 paste0(gfc_dir,"tmp_merge_",type,".tif")
  ))
  print(to_merge)
  }
  }

####################################################################################
####### COMBINE GFC LAYERS
####################################################################################

#################### CREATE GFC TREE COVER MAP IN beginning year AT THRESHOLD
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(gfc_dir,"gfc_treecover2000.tif"),
               paste0(gfc_dir,"gfc_lossyear.tif"),
               paste0(dd_dir,"tmp_gfc_",startyear,"_gt",gfc_threshold,".tif"),
               paste0("(A>",gfc_threshold,")*((B==0)+(B>",startyear1-1,"))*A")
))
}
#################### CREATE GFC LOSS MAP AT THRESHOLD between start year and end year
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
  
  system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(gfc_dir,"gfc_treecover2000.tif"),
               paste0(gfc_dir,"gfc_lossyear.tif"),
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,".tif"),
               paste0("(A>",gfc_threshold,")*(B>",startyear1-1,")*(B<",endyear1+1,")")
))
}
#################### SIEVE TO THE MMU
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
  system(sprintf("gdal_sieve.py -st %s %s %s ",
               mmu,
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,".tif"),
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,"_sieve.tif")
))
}
#################### DIFFERENCE BETWEEN SIEVED AND ORIGINAL
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,".tif"),
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,"_sieve.tif"),
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,"_inf.tif"),
               paste0("(A>0)*(A-B)+(A==0)*(B==1)*0")
))
}

#################### CREATE GFC TREE COVER MASK IN end year AT THRESHOLD
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(dd_dir,"tmp_gfc_",startyear,"_gt",gfc_threshold,".tif"),
               paste0(gfc_dir,"gfc_lossyear.tif"),
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,".tif"),
               paste0("(A>0)*((B>=",endyear1+1,")+(B==0))")
))
}

#################### SIEVE TO THE MMU
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_sieve.py -st %s %s %s ",
               mmu,
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,".tif"),
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,"_sieve.tif")
))
}
#################### DIFFERENCE BETWEEN SIEVED AND ORIGINAL
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,".tif"),
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,"_sieve.tif"),
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,"_inf.tif"),
               paste0("(A>0)*(A-B)+(A==0)*(B==1)*0")
))
}  
plot(raster(paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,"_inf.tif")))
#################### COMBINATION INTO DD MAP (1==NF, 2==F, 3==Df, 4==Dg, 5=gain)
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_calc.py -A %s -B %s -C %s -D %s -E %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(dd_dir,"tmp_gfc_",startyear,"_gt",gfc_threshold,".tif"),
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,"_sieve.tif"),
               paste0(dd_dir,"tmp_gfc_loss_",startyear1,endyear1,"_gt",gfc_threshold,"_inf.tif"),
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,"_sieve.tif"),
               paste0(dd_dir,"tmp_gfc_",endyear,"_gt",gfc_threshold,"_inf.tif"),
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,".tif"),
               paste0("(A==0)*1+(A>0)*((B==0)*(C==0)*((D>0)*2+(E>0)*1)+(B>0)*3+(C>0)*4)")
))
}
# gdalinfo(paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,".tif"),mm=T)
plot(raster(paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,".tif")))
################################################################################
#################### PROJECT IN UTM 30
################################################################################
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdalwarp -t_srs \"%s\" -overwrite -ot Byte -co COMPRESS=LZW %s %s",
               "EPSG:32630",
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,".tif"),
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm.tif")
))
}
#################### Create a country boundary mask at the GFC resolution (TO BE REPLACED BY NATIONAL DATA IF AVAILABLE) 
# system(sprintf("python %s/oft-rasterize_attr.py -v %s -i %s -o %s -a %s",
#                '~/liberia_activity_data/scripts/',
#                paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.shp"),
#                paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm.tif"),
#                paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.tif"),
#                "OBJECTID"
# ))

#################### CLIP TO COUNTRY BOUNDARIES
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_calc.py -A %s -B %s  --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm.tif"),
               paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.tif"),
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_country.tif"),
               paste0("(B>0)*A")
))
}
#################### CREATE A COLOR TABLE FOR THE OUTPUT MAP
my_classes <- c(0,1,2,3,4,11)
my_colors  <- col2rgb(c("black","grey","darkgreen","red","orange","purple"))

pct <- data.frame(cbind(my_classes,
                        my_colors[1,],
                        my_colors[2,],
                        my_colors[3,]))

write.table(pct,paste0(dd_dir,"color_table.txt"),row.names = F,col.names = F,quote = F)

################################################################################
#################### Add pseudo color table to result
################################################################################
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(dd_dir,"color_table.txt"),
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_country.tif"),
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"pct.tif")
))
}
################################################################################
#################### COMPRESS
################################################################################
if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(dd_dir,"tmp_dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"pct.tif"),
               paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif")
))
}

################################################################################
####################  CLEAN
################################################################################
system(sprintf("rm %s",
               paste0(dd_dir,"tmp*.tif")
))

(time_decision_tree <- Sys.time() - time_start)

