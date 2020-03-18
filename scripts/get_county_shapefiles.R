library(tigris)
library(sf)
setwd(here::here())
get_county <- function(x){
  cat(paste0(x, " starting\n"))
  acounty <- st_as_sf(counties(x, cb=TRUE))
  cat(paste0(x, " saving\n"))
  saveRDS(acounty, file = paste0("./counties/", x, ".rds"))
  cat(paste0(x, " done\n"))
}

get_county("Massachusetts")


us_map <- rnaturalearth::ne_states(country = "United States of America", returnclass = "sf")


sapply(sort(unique(us_map$name)), get_county)
