####################################################################################################
####################################################################################################
## Read, manipulate and write spatial vector data, Get GADM data
## Contact remi.dannunzio@fao.org 
## 2018/08/22
####################################################################################################
####################################################################################################


####################################################################################################
################################### PART I: GET GADM DATA
####################################################################################################

## Get the list of countries from getData: "getData"
(gadm_list  <- data.frame(raster::getData('ISO3')))

## Get GADM data, check object properties
country         <- raster::getData('GADM',path=gadm_dir , country= countrycode, level=1)

summary(country)
extent(country)
proj4string(country)

## Display the SPDF
plot(country)

country$OBJECTID <- row(country)[,1]

##  Export the SpatialPolygonDataFrame as a ESRI Shapefile
writeOGR(country,
         paste0(gadm_dir,"gadm_",countrycode,"_l1.shp"),
         paste0("gadm_",countrycode,"_l1"),
         "ESRI Shapefile",
         overwrite_layer = T)


####################################################################################################
################################### PART II: CREATE A TILING OVER AN AREA OF INTEREST
####################################################################################################

### What grid size do we need ? 
grid_size <- 20000          ## in meters
grid_deg  <- grid_size/111320 ## in degree


sqr_df <- generate_grid(country,grid_deg)

nrow(sqr_df)

### Select a vector from location of another vector
aoi <- readOGR(paste0(phu_dir,"107_PHU_BOUNDARY.shp"))

#aoi_3phu <- aoi[aoi$KODE_KHG %in% c("KHG.16.02.01","KHG.16.02.08","KHG.16.02.02"),]

### Select a vector from location of another vector
sqr_df_selected <- sqr_df[aoi,]

nrow(sqr_df_selected)

### Plot the results
plot(sqr_df_selected)
plot(aoi,add=T,border="blue")
plot(country,add=T,border="green")

### Give the output a decent name, with unique ID
names(sqr_df_selected@data) <- "tileID" 
sqr_df_selected@data$tileID <- row(sqr_df_selected@data)[,1]

tiles <- sqr_df_selected



### Distribute samples among users
dt <- tiles@data

users <- read.csv(paste0(doc_dir,"participants_workshop_20190611.csv"))

du    <- data.frame(cbind(users$UserName,dt$tileID))
names(du) <- c("username","tileID")
du <- arrange(du,username)

df <- data.frame(cbind(du$username,dt$tileID))

names(df) <- c("username","tileID")

df$tileID <- as.numeric(df$tileID)
table(df$username)


tiles@data <- df

### Export ALL TILES as KML
export_name <- paste0("tiling_all_phu")

writeOGR(obj=tiles,
         dsn=paste(tile_dir,export_name,".kml",sep=""),
         layer= export_name,
         driver = "KML",
         overwrite_layer = T)


### Create a final subset corresponding to your username
my_tiles <- tiles[tiles$tileID %in% df[df$username == username,"tileID"],]
plot(my_tiles,add=T,col="red")

### Export the final subset
export_name <- paste0("tiles_phu_",username)

writeOGR(obj=my_tiles,
         dsn=paste(tile_dir,export_name,".kml",sep=""),
         layer= export_name,
         driver = "KML",
         overwrite_layer = T)

