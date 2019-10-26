## prepare forest mask for MSPA analysis
# land cover map
source('~/uga_activity_data/scripts/get_parameters.R')

lc <- paste0(lc_dir,'Ug2017_CW_gEdits4_co.tif')

# output mask for MSPA analysis
mspa_mask <- paste0(mspa_dir,'THF_mask_MSPA.tif')
#################### reclassify LC map into THF mask
system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               lc,
               mspa_mask,
               paste0("((A==3)+(A==4))*2+((A<3)+(A>4))*1")
))
#################### reproject THF mask to latlong WGS84
system(sprintf("gdalwarp -t_srs \"%s\" -overwrite -ot Byte -co COMPRESS=LZW %s %s",
               "EPSG:4326",
               mspa_mask,
               paste0(mspa_dir,"proj.tif")
))
gdalinfo(mspa_mask,mm=T)
plot(raster(mspa_mask))
