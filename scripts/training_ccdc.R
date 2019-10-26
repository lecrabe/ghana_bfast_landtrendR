####################################################################################################
####################################################################################################
## Use the sample data from Collect Earth as training data in CCDC
## Contact yelena.finegold@fao.org
## updated: 2019/10/17
####################################################################################################
####################################################################################################
## read CE data for Ghana

ce_filename <- 'africa_deal_ghana.csv'

prj_bnd_filename <- 'cocoa_project_ghana_dissolved.shp' 
countrycode <- 'GHA'
# read the CE data
ce <- read.csv(paste0(samp_dir,ce_filename))
head(ce)

# read the project area boundary file
prj_bnd <- readOGR(paste0(gadm_dir,prj_bnd_filename))

## plot the reference data
plot(ce$location_x,ce$location_y)

#download province boundaries
adm <- getData ('GADM', country= countrycode, level=1)

## plot administrative boundaries on top of the points
plot(adm, add=T,border='red')
### some guiding questions
## how are the samples distributed by region?
table(ce$province)

## how many samples where distributed by 2018 land cover?
table(ce$land_use_category_label)

## how are samples distributed for 2018 land cover subcategory?
table(ce$land_use_subcategory_label)
###############################################################################
################### READ THE SPATIAL DATA
###############################################################################

## read the reference data as spatial data
coord <- coordinates(cbind(ce$location_x,ce$location_y))
coord.sp <- SpatialPoints(coord)
coord.df <- as.data.frame(ce)
coord.spdf <- SpatialPointsDataFrame(coord.sp, coord.df)

## match the coordinate systems for the sample points and the boundaries
proj4string(coord.spdf) <-proj4string(prj_bnd)

###############################################################################
################### EXTRACT DATA OVER REFERENCE DATA SAMPLES
###############################################################################
## extract the forest management data for each sample in the reference data
ce_prj <- over( coord.spdf,prj_bnd)
head(ce_prj)
table(ce_prj$OBJECTID)
## if the value is NA is private lands, reassign privates to the value 1
ce_prj$OBJECTID[!is.na(ce_prj$OBJECTID)] <- 1

## add the forest management information as a column in the reference data
coord.spdf$project_area <- ce_prj$OBJECTID

coord.spdf.cocoa <- coord.spdf[!is.na(coord.spdf$project_area),]
plot(coord.spdf.cocoa)


## create a subset to use as training data for ccdc
table(coord.spdf.cocoa$land_use_category)
table(coord.spdf.cocoa$land_useF_percentage)
table(coord.spdf.cocoa$land_use_category,coord.spdf.cocoa$land_useF_percentage)
table(coord.spdf.cocoa$land_use_category,coord.spdf.cocoa$vhri_year_label)
traindata <- coord.spdf.cocoa[!is.na(coord.spdf.cocoa$vhri_year_label),]
table(traindata$land_use_category)
traindata$type[traindata$land_use_category %in% 'F'] <- 0
traindata$type[!traindata$land_use_category %in% 'F'] <- 1
traindata$date <- paste0(traindata$vhri_year_label,'-01-01')
table(traindata$fnf)
newdata <- traindata[c('type','date')]
writeOGR(newdata,paste0(samp_dir,'fnf_ccdc_training.shp'),layer = 'fnf_ccdc_training.shp',driver = 'ESRI Shapefile')
