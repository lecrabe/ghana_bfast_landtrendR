####################################################################################################
####################################################################################################
## Set environment variables
## Contact remi.dannunzio@fao.org 
## 2019/06/11
####################################################################################################
####################################################################################################
####################################################################################################

## Set the country code
countrycode <- "GHA"
nbatchmax <- 10

## parameters
threshold <- 30
max_year  <- 18

## grid size in meters
grid_size <- 20000          

aoi_list    <- countrycode
#proj <- '+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs '
ghana_proj <- '2136'

## Set the working directory
rootdir       <- "~/ghana_bfast_landtrenR/"
setwd(rootdir)
rootdir  <- paste0(getwd(),"/")
username <- unlist(strsplit(rootdir,"/"))[3]

############ USER-DEFINED DIRECTORIES
aoi_dir   <- paste0(rootdir,"data/gcfrp_area/")
aoi_path  <- paste0(aoi_dir,"cocoa_project.kml")
operators <- paste0(rootdir,"participants_workshop_20190618.csv")


############ FIXED DIRECTORIES
gfcdwn_dir  <- "~/downloads/gfc/2018/"

scriptdir <- paste0(rootdir,"scripts/")
doc_dir   <- paste0(rootdir,"docs/")
data_dir  <- paste0(rootdir,"data/")
gadm_dir  <- paste0(rootdir,"data/gadm/")
tile_dir  <- paste0(rootdir,"data/tiling/")
ts_dir    <- paste0("/home/",username,"/downloads/tiles_",countrycode,"/")
bfst_dir  <- paste0(rootdir,"data/bfast_",countrycode,"_",username,"/")
gfc_dir   <- paste0(rootdir,"data/gfc/")
tmp_dir     <- paste0(rootdir,"tmp/")


############ CREATE DEFAULT DIRECTORIES
dir.create(gadm_dir,showWarnings = F)
dir.create(tile_dir,showWarnings = F)
dir.create(bfst_dir,showWarnings = F)
dir.create(gfcdwn_dir,showWarnings = F)
dir.create(gfc_dir,showWarnings = F)
dir.create(tmp_dir,showWarnings = F)


### Read all external files with TEXT as TEXT
options(stringsAsFactors = FALSE)

### Create a function that checks if a package is installed and installs it otherwise
packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

### Install (if necessary) two missing packages in your local SEPAL environment
packages(Hmisc)
packages(lubridate)

### Load necessary packages
packages(raster)
packages(rgeos)
packages(rgdal)


packages(readxl)

packages(dplyr)
packages(ggplot2)
packages(reshape2)

packages(gfcanalysis)

packages(maptools)
########################### CREATE A FUNCTION TO GENERATE A GRID
generate_grid <- function(aoi,size){
  ### Create a set of regular SpatialPoints on the extent of the created polygons  
  sqr <- SpatialPoints(makegrid(aoi,offset=c(0.5,0.5),cellsize = size))
  
  ### Convert points to a square grid
  grid <- points2grid(sqr)
  
  ### Convert the grid to SpatialPolygonDataFrame
  SpP_grd <- as.SpatialPolygons.GridTopology(grid)
  
  sqr_df <- SpatialPolygonsDataFrame(Sr=SpP_grd,
                                     data=data.frame(rep(1,length(SpP_grd))),
                                     match.ID=F)
  
  ### Assign the right projection
  proj4string(sqr_df) <- proj4string(aoi)
  sqr_df
}

#################### CREATE A COLOR TABLE FOR THE OUTPUT MAP
my_classes <- c(0,1:max_year,30,40,50,51)
my_labels  <- c("no data",paste0("loss_",2000+1:max_year),"non forest","forest","gains","gains+loss")
codes <- data.frame(cbind(my_labels,my_classes))

loss_col <- colorRampPalette(c("yellow", "darkred"))
nonf_col <- "lightgrey"
fore_col <- "darkgreen"
gain_col <- "lightgreen"
ndat_col <- "black"
gnls_col <- "purple"

my_colors  <- col2rgb(c(ndat_col,
                        loss_col(max_year),
                        nonf_col,
                        fore_col,
                        gain_col,
                        gnls_col))

pct <- data.frame(cbind(my_classes,
                        my_colors[1,],
                        my_colors[2,],
                        my_colors[3,]))

write.table(pct,paste0(gfc_dir,"color_table.txt"),row.names = F,col.names = F,quote = F)

types       <- c("treecover2000","lossyear","gain","datamask")

pixel_count <- function(x){
  info    <- gdalinfo(x,hist=T)
  buckets <- unlist(str_split(info[grep("bucket",info)+1]," "))
  buckets <- as.numeric(buckets[!(buckets == "")])
  hist    <- data.frame(cbind(0:(length(buckets)-1),buckets))
  hist    <- hist[hist[,2]>0,]
}

################ AOI FOR GFC MAP
country   <- getData('GADM',
                 path=gadm_dir,
                 country= countrycode,
                 level=0)

country <- spTransform(country,CRS('+init=epsg:4326'))
(bb    <- extent(country))

country_name   <- paste0(gadm_dir,'GADM_',countrycode)
country_shp    <- paste0(country_name,".shp")
country_field <-  "id_country"
country@data[,country_field] <- row(country)[,1]

writeOGR(obj = country,
         dsn = country_shp,
         layer = country_name,
         driver = "ESRI Shapefile",
         overwrite_layer = T)


proj <- CRS(paste0('+init=epsg:',ghana_proj))

print(paste0("I am running for ",username))
