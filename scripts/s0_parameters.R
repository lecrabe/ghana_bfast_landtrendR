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
scriptdir <- paste0(rootdir,"scripts/")
doc_dir   <- paste0(rootdir,"docs/")
data_dir  <- paste0(rootdir,"data/")
gadm_dir  <- paste0(rootdir,"data/gadm/")
tile_dir  <- paste0(rootdir,"data/tiling/")
ts_dir    <- paste0("/home/",username,"/downloads/tiles_",countrycode,"/")
bfst_dir  <- paste0(rootdir,"data/bfast_",countrycode,"_",username,"/")

############ CREATE DEFAULT DIRECTORIES
dir.create(gadm_dir,showWarnings = F)
dir.create(tile_dir,showWarnings = F)
dir.create(bfst_dir,showWarnings = F)



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

print(paste0("I am running for ",username))

      