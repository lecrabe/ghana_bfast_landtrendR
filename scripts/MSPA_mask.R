## prepare forest mask for MSPA analysis
# land cover map
source('~/ghana_bfast_landtrendR/scripts/s0_parameters.R')

lc <- paste0(lc_dir,'forest_mask_2000_2015.tif')

# output mask for MSPA analysis
mspa_mask <- paste0(mspa_dir,'forest_mask_MSPA.tif')
#################### reclassify LC map into THF mask
system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               lc,
               mspa_mask,
               paste0("((A==1))*2+((A<1))*1")
))
#################### reproject forest mask to latlong WGS84
system(sprintf("gdalwarp -t_srs \"%s\" -overwrite -ot Byte -co COMPRESS=LZW %s %s",
               "EPSG:4326",
               mspa_mask,
               paste0(mspa_dir,"proj.tif")
))
# gdalinfo(mspa_mask,mm=T)
plot(raster(mspa_mask))
