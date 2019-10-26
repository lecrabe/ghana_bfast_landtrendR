####################################################################################################
####################################################################################################
## Create a forest mask
## Contact yelena.finegold@fao.org
## updated: 2019/10/17
####################################################################################################
####################################################################################################

### combine the land cover maps to derive maximum forest cover

## user parameters to get directory names
source('~/gha_activity_data/scripts/get_parameters.R')

## create variables for all the land cover maps
lc2000 <- paste0(lc_dir,'landuse_maps/Landuse_2000.tif')
lc2010 <- paste0(lc_dir,'landuse_maps/Landuse_2010.tif')
lc2012 <- paste0(lc_dir,'landuse_maps/Landuse_2012.tif')
lc2015 <- paste0(lc_dir,'landuse_maps/Landuse_2015.tif')
lc2018 <- paste0(lc_dir,'landuse_maps/Landuse_2018.tif')

## make sure all the maps perfectly align
## using the 2018 land cover map as the reference map 
## match the extent of the 2 LC maps -- using the extent of 2018
bb<- extent(raster(lc2018))
lc2000.aligned <- paste0(substr(lc2000, 1, nchar(lc2000)-4),'_aligned','.tif')
lc2010.aligned <- paste0(substr(lc2010, 1, nchar(lc2010)-4),'_aligned','.tif')
lc2012.aligned <- paste0(substr(lc2012, 1, nchar(lc2012)-4),'_aligned','.tif')
lc2015.aligned <- paste0(substr(lc2015, 1, nchar(lc2015)-4),'_aligned','.tif')

if(!file.exists(lc2000.aligned)){
  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 lc2000,
                 lc2000.aligned
  ))
}
if(!file.exists(lc2010.aligned)){
  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 lc2010,
                 lc2010.aligned
  ))
}
if(!file.exists(lc2012.aligned)){
  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 lc2012,
                 lc2012.aligned
  ))
}
if(!file.exists(lc2015.aligned)){
  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 lc2015,
                 lc2015.aligned
  ))
}

## create a maximum forest cover mask for 2000-2015
forestmask <- paste0(fmask_dir, 'forest_mask_2000_2015.tif')

if(!file.exists(forestmask)){
  system(sprintf("gdal_calc.py -A %s -B %s -C %s -D %s --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
                 lc2000.aligned,
                 lc2010.aligned,
                 lc2012.aligned,
                 lc2015.aligned,
                 forestmask,
                 paste0("(A<3)*(B<3)*(C<3)*(D<3)*1")
))
}
gdalinfo(forestmask,mm=T)
plot(raster(forestmask))


################### COMPRESS
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               lc2000,
               paste0(substr(lc2000, 1, nchar(lc2000)-4),'_comp','.tif')
))
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               lc2010,
               paste0(substr(lc2010, 1, nchar(lc2010)-4),'_comp','.tif')
))
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               lc2012,
               paste0(substr(lc2012, 1, nchar(lc2012)-4),'_comp','.tif')
))
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               lc2015,
               paste0(substr(lc2015, 1, nchar(lc2015)-4),'_comp','.tif')
))
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               lc2018,
               paste0(substr(lc2018, 1, nchar(lc2018)-4),'_comp','.tif')
))
