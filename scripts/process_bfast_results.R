#### combine BFAST results

## after downloading all the bfast results... 
# LOAD PARAMETERS
source('~/ghana_bfast_landtrendR/scripts/s0_parameters.R')

############### MAKE A LIST OF RESULTS
list_res <- list.files(bfst_res_dir,pattern = glob2rx(paste0("*",".tif")),full.names = T)
title <-'all_bfast_2005_2014_cocoa_project'

system(sprintf("gdal_merge.py -co COMPRESS=LZW -o %s %s",
               paste0(bfst_mrg_dir,title,".tif"),
               paste0(list_res,collapse=' ')
))

################################################################################
#################### PROJECT IN UTM 30
################################################################################
# if(!file.exists(paste0(bfst_mrg_dir,title,"_utm30n.tif"))){
  system(sprintf("gdalwarp -t_srs \"%s\" -overwrite %s %s",
                 "EPSG:32630",
                 paste0(bfst_mrg_dir,title,".tif"),
                 paste0(bfst_mrg_dir,title,"_utm30n.tif")
  ))
# }
gdalinfo(paste0(bfst_mrg_dir,title,"_utm30n.tif"))

####################  EXTRACT MAGNITUDE
system(sprintf("gdal_translate -b 2 %s %s",
               paste0(bfst_mrg_dir,title,"_utm30n.tif"),
               paste0(bfst_mrg_dir,title,"_utm30n_magnitude.tif")
))

## mask out non-forest
forestmask <- paste0(fmask_dir, 'forest_mask_2000_2015.tif')
bb<- extent(raster(forestmask))
# if(!file.exists(paste0(bfst_mrg_dir,title,"_aligned.tif"))){
system(sprintf("gdal_translate -tr %s %s  -projwin %s %s %s %s %s %s",
               res(raster(forestmask))[1],
               res(raster(forestmask))[2],
               floor(bb@xmin),
               ceiling(bb@ymax),
               ceiling(bb@xmax),
               floor(bb@ymin),
               paste0(bfst_mrg_dir,title,"_utm30n_magnitude.tif"),
               paste0(bfst_mrg_dir,title,"_fm_aligned.tif")
))
# }
system(sprintf("gdal_calc.py -A %s -B %s --outfile=%s --calc=\"%s\"",
               paste0(bfst_mrg_dir,title,"_fm_aligned.tif"),
               forestmask,
               paste0(bfst_mrg_dir,title,"_forest_mask.tif"),
               paste0("(B>0)*A")
))
# gdalinfo(paste0(bfst_mrg_dir,title,"_forest_mask.tif"))
project.area <- paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.tif")
bb <- extent(raster(project.area))
reso <- strsplit(gdalinfo(project.area)[28],"[, ()]+")[[1]][4]
xmin <- strsplit(gdalinfo(project.area)[35],"[, ()]+")[[1]][3]
ymax <- strsplit(gdalinfo(project.area)[35],"[, ()]+")[[1]][4]
xmax <- strsplit(gdalinfo(project.area)[38],"[, ()]+")[[1]][3]
ymin <- strsplit(gdalinfo(project.area)[38],"[, ()]+")[[1]][4]
outsizex <- strsplit(gdalinfo(project.area)[3],"[, ()]+")[[1]][3]
outsizey <- strsplit(gdalinfo(project.area)[3],"[, ()]+")[[1]][4]

# if(!file.exists(paste0(bfst_mrg_dir,title,"_pa_aligned.tif"))){
# system(sprintf("gdal_translate -tr %s %s  -projwin %s %s %s %s %s %s",
#                reso,
#                reso,
#                xmin,
#                ymax,
#                xmax,
#                ymin,
#                paste0(bfst_mrg_dir,title,"_forest_mask.tif"),
#                paste0(bfst_mrg_dir,title,"_pa_aligned.tif")
# ))
system(sprintf("gdal_translate -outsize %s %s  -projwin %s %s %s %s %s %s",
               outsizex,
               outsizey,
               xmin,
               ymax,
               xmax,
               ymin,
               paste0(bfst_mrg_dir,title,"_forest_mask.tif"),
               paste0(bfst_mrg_dir,title,"_pa_aligned.tif")
))

# }
# gdalinfo(project.area)
# gdalinfo(paste0(bfst_mrg_dir,title,"_pa_aligned.tif"))
# ### crop result to project area
# if(!file.exists(paste0(dd_dir,"dd_map_",startyear1,endyear1,"_gt",gfc_threshold,"_utm_20191017.tif"))){
system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(bfst_mrg_dir,title,"_pa_aligned.tif"),
               paste0(gadm_dir,"cocoa_project_ghana_30nutm_dissolved.tif"),
               paste0(bfst_mrg_dir,title,"_project_area.tif"),
               paste0("(B>0)*A")
))
# gdalinfo(paste0(bfst_mrg_dir,title,"_project_area.tif"))
# }
# ####################  CREATE A VRT OUTPUT
# system(sprintf("gdalbuildvrt %s %s",
#                paste0(bfast_results_dir,"all_bfast_results_cocoa_project.vrt"),
#                paste0(list_res,collapse=' ')
# ))

## Compress final result
# system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
#                paste0(bfast_results_dir,"all_bfast_results_cocoa_project.vrt"),
#                paste0(bfast_results_dir,"all_bfast_results_cocoa_project.tif")
# ))


####################  COMPUTE  STATS FOR MAGNITUDE
stats <- paste0(bfst_mrg_dir,title,".txt")
# factor to multiply standard deviation
mult_sd <- 3


system(sprintf("gdalinfo -stats %s > %s",
               paste0(bfst_mrg_dir,title,"_project_area.tif"),
               stats
))

s <- readLines(stats)
maxs_b2   <- as.numeric(unlist(strsplit(s[grepl("STATISTICS_MAXIMUM",s)],"="))[2])
mins_b2   <- as.numeric(unlist(strsplit(s[grepl("STATISTICS_MINIMUM",s)],"="))[2])
means_b2  <- as.numeric(unlist(strsplit(s[grepl("STATISTICS_MEAN",s)],"="))[2])
stdevs_b2 <- as.numeric(unlist(strsplit(s[grepl("STATISTICS_STDDEV",s)],"="))[2])
stdevs_b2 <- stdevs_b2 * mult_sd
num_class <-9
eq.reclass <-   paste0('(A<=',(maxs_b2),")*", '(A>',(means_b2+(stdevs_b2*floor(num_class/2))),")*",num_class,"+" ,
                       paste( 
                         " ( A >",(means_b2+(stdevs_b2*1:(floor(num_class/2)-1))),") *",
                         " ( A <=",(means_b2+(stdevs_b2*2:floor(num_class/2))),") *",
                         (ceiling(num_class/2)+1):(num_class-1),"+",
                         collapse = ""), 
                       '(A<=',(means_b2+(stdevs_b2)),")*",
                       '(A>', (means_b2-(stdevs_b2)),")*1+",
                       '(A>=',(mins_b2),")*",
                       '(A<', (means_b2-(stdevs_b2*4)),")*",ceiling(num_class/2),"+",
                       paste( 
                         " ( A <",(means_b2-(stdevs_b2*1:(floor(num_class/2)-1))),") *",
                         " ( A >=",(means_b2-(stdevs_b2*2:floor(num_class/2))),") *",
                         2:(ceiling(num_class/2)-1),"+",
                         collapse = "")
)
eq.reclass2 <- as.character(substr(eq.reclass,1,nchar(eq.reclass)-2))

####################  COMPUTE THRESHOLDS LAYER
system(sprintf("gdal_calc.py -A %s --co=COMPRESS=LZW --type=Byte --overwrite --outfile=%s --calc=\"%s\"",
               paste0(bfst_mrg_dir,title,"_project_area.tif"),
               paste0(bfst_mrg_dir,"tmp_results_",title,"_magnitude.tif"),
               eq.reclass2
               
))     

####################  CREATE A PSEUDO COLOR TABLE
cols <- col2rgb(c("black","beige","yellow","orange","red","darkred","palegreen","green2","forestgreen",'darkgreen'))
pct <- data.frame(cbind(c(0:9),
                        cols[1,],
                        cols[2,],
                        cols[3,]
))

write.table(pct,paste0(bfst_mrg_dir,'color_table.txt'),row.names = F,col.names = F,quote = F)

################################################################################
## Add pseudo color table to result
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(bfst_mrg_dir,'color_table.txt'),
               paste0(bfst_mrg_dir,"tmp_results_",title,"_magnitude.tif"),
               paste0(bfst_mrg_dir,"tmp_results_",title,"_magnitude_pct.tif")
))

## Compress final result
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(bfst_mrg_dir,"tmp_results_",title,"_magnitude_pct.tif"),
               paste0(bfst_mrg_dir,"results_",title,"_threshold.tif")
))
plot(raster(paste0(bfst_mrg_dir,"results_",title,"_threshold.tif")))
# system(sprintf("rm -r -f %s",
#                paste0(bfst_mrg_dir,"tmp*.tif"))
# )


